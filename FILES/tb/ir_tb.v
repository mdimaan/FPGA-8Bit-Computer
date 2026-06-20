`timescale 1ns/1ps

module ir_tb;

    reg clk, reset, EN, II;
    reg [7:0] bus_in;
    wire [7:0] ir_out;
    wire [3:0] opcode, operand;
    integer errors = 0;

    ir UUT (
        .clk(clk), .reset(reset), .EN(EN), .II(II),
        .bus_in(bus_in), .ir_out(ir_out),
        .opcode(opcode), .operand(operand)
    );

    always #5 clk = ~clk;

    task check_ir(input [7:0] exp_ir, input [3:0] exp_op, input [3:0] exp_opd, input [255:0] msg);
        begin
            if (ir_out !== exp_ir || opcode !== exp_op || operand !== exp_opd) begin
                $display("FAIL: %0s | expected ir=%h op=%h opd=%h actual ir=%h op=%h opd=%h time=%0t",
                          msg, exp_ir, exp_op, exp_opd, ir_out, opcode, operand, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | ir=%h op=%h opd=%h time=%0t", msg, ir_out, opcode, operand, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("ir_tb.vcd");
        $dumpvars(0, ir_tb);

        clk = 0; reset = 1; EN = 0; II = 0; bus_in = 8'h00;
        @(posedge clk); @(posedge clk);
        check_ir(8'h00, 4'h0, 4'h0, "reset clears IR");

        reset = 0; EN = 1; II = 1; bus_in = 8'b0001_0101; // ADD addr 5
        @(posedge clk); #1; check_ir(8'h15, 4'h1, 4'h5, "load ADD addr5 (0x15)");

        bus_in = 8'b1111_0000; // HLT
        @(posedge clk); #1; check_ir(8'hF0, 4'hF, 4'h0, "load HLT (0xF0)");

        II = 0; bus_in = 8'hAA;
        @(posedge clk); #1; check_ir(8'hF0, 4'hF, 4'h0, "II=0 holds previous value");

        II = 1; EN = 0;
        @(posedge clk); #1; check_ir(8'hF0, 4'hF, 4'h0, "EN=0 blocks load despite II=1");

        EN = 1;
        @(posedge clk); #1; check_ir(8'hAA, 4'hA, 4'hA, "EN=1 restores load capability (0xAA)");

        if (errors == 0)
            $display("IR_TB: ALL TESTS PASSED");
        else
            $display("IR_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
