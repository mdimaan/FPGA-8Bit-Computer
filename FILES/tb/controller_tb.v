`timescale 1ns/1ps

module controller_tb;

    reg [4:0] step;
    reg [3:0] opcode;
    reg zero_flag;

    wire CO, CE, MI, RO, RI, II, IO, AI, AO, BI, OI, LP, SU, EO, FI, HLT;
    integer errors = 0;

    localparam T1=5'b00001, T2=5'b00010, T3=5'b00100, T4=5'b01000, T5=5'b10000;
    localparam OP_LDA=4'b0000, OP_ADD=4'b0001, OP_SUB=4'b0010, OP_STA=4'b0011,
               OP_JMP=4'b0100, OP_JZ=4'b0101, OP_OUT=4'b1110, OP_HLT=4'b1111;

    controller UUT (
        .step(step), .opcode(opcode), .zero_flag(zero_flag),
        .CO(CO), .CE(CE), .MI(MI), .RO(RO), .RI(RI), .II(II), .IO(IO),
        .AI(AI), .AO(AO), .BI(BI), .OI(OI), .LP(LP), .SU(SU), .EO(EO),
        .FI(FI), .HLT(HLT)
    );

    function [15:0] pack;
        input dCO,dCE,dMI,dRO,dRI,dII,dIO,dAI,dAO,dBI,dOI,dLP,dSU,dEO,dFI,dHLT;
        begin
            pack = {dCO,dCE,dMI,dRO,dRI,dII,dIO,dAI,dAO,dBI,dOI,dLP,dSU,dEO,dFI,dHLT};
        end
    endfunction

    task check(input [15:0] expected, input [255:0] msg);
        reg [15:0] actual;
        begin
            #1;
            actual = pack(CO,CE,MI,RO,RI,II,IO,AI,AO,BI,OI,LP,SU,EO,FI,HLT);
            if (actual !== expected) begin
                $display("FAIL: %0s | expected=%b actual=%b", msg, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | signals=%b", msg, actual);
            end
        end
    endtask

    initial begin
        $dumpfile("controller_tb.vcd");
        $dumpvars(0, controller_tb);

        opcode = OP_LDA; zero_flag = 0;
        step = T1; check(pack(1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0), "FETCH T1: CO,MI");
        step = T2; check(pack(0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0), "FETCH T2: RO,II,CE");

        opcode = OP_LDA;
        step = T3; check(pack(0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0), "LDA T3: IO,MI");
        step = T4; check(pack(0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0), "LDA T4: RO,AI");
        step = T5; check(pack(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), "LDA T5: NOP");

        opcode = OP_ADD;
        step = T3; check(pack(0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0), "ADD T3: IO,MI");
        step = T4; check(pack(0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0), "ADD T4: RO,BI");
        step = T5; check(pack(0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0), "ADD T5: EO,AI,FI,SU=0");

        opcode = OP_SUB;
        step = T3; check(pack(0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0), "SUB T3: IO,MI");
        step = T4; check(pack(0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0), "SUB T4: RO,BI");
        step = T5; check(pack(0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,0), "SUB T5: EO,AI,FI,SU=1");

        opcode = OP_STA;
        step = T3; check(pack(0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0), "STA T3: IO,MI");
        step = T4; check(pack(0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0), "STA T4: AO,RI");

        opcode = OP_JMP;
        step = T3; check(pack(0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0), "JMP T3: IO,LP");

        opcode = OP_JZ; zero_flag = 1;
        step = T3; check(pack(0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0), "JZ T3 (ZF=1): IO,LP (taken)");

        zero_flag = 0;
        step = T3; check(pack(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), "JZ T3 (ZF=0): NOP (not taken)");

        opcode = OP_OUT;
        step = T3; check(pack(0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0), "OUT T3: AO,OI");

        opcode = OP_HLT;
        step = T3; check(pack(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1), "HLT T3: HLT");

        if (errors == 0)
            $display("CONTROLLER_TB: ALL TESTS PASSED");
        else
            $display("CONTROLLER_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
