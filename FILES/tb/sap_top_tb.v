`timescale 1ns/1ps

module sap_top_tb;

    reg        CLK100MHZ;
    reg [15:0] SW;
    wire [6:0] SEG;
    wire [3:0] AN;

    integer errors = 0;

    sap_top dut (
        .CLK100MHZ (CLK100MHZ),
        .SW        (SW),
        .SEG       (SEG),
        .AN        (AN)
    );

    always #5 CLK100MHZ = ~CLK100MHZ;

    task prog_write_byte(input [3:0] addr, input [7:0] data);
        begin
            SW[3:0]  = addr;
            SW[11:4] = data;
            SW[12]   = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
            SW[12]   = 1'b1;
            repeat (3) @(posedge CLK100MHZ);
            SW[12]   = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
        end
    endtask

    task step_once;
        begin
            SW[15] = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
            SW[15] = 1'b1;
            repeat (3) @(posedge CLK100MHZ);
        end
    endtask

    task do_reset;
        begin
            SW[14] = 1'b1;
            repeat (3) @(posedge CLK100MHZ);
            SW[14] = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
        end
    endtask

    task check8(input [7:0] actual, input [7:0] expected, input [255:0] msg);
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h time=%0t", msg, expected, actual, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | value=%h time=%0t", msg, actual, $time);
            end
        end
    endtask

    task check1(input actual, input expected, input [255:0] msg);
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s | expected=%b actual=%b time=%0t", msg, expected, actual, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | value=%b time=%0t", msg, actual, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("sap_top_tb.vcd");
        $dumpvars(0, sap_top_tb);

        CLK100MHZ = 0;
        SW = 16'h0000;

        SW[14] = 1; repeat (4) @(posedge CLK100MHZ); SW[14] = 0;
        repeat (4) @(posedge CLK100MHZ);

        SW[13] = 0;
        prog_write_byte(4'd0,  8'h09); 
        prog_write_byte(4'd1,  8'h2A);
        prog_write_byte(4'd2,  8'h56); 
        prog_write_byte(4'd3,  8'hE0); 
        prog_write_byte(4'd4,  8'hF0); 
        prog_write_byte(4'd6,  8'h0B); 
        prog_write_byte(4'd7,  8'hE0); 
        prog_write_byte(4'd8,  8'hF0);
        prog_write_byte(4'd9,  8'h05); 
        prog_write_byte(4'd10, 8'h05); 
        prog_write_byte(4'd11, 8'h2A); 

        do_reset();

        SW[13] = 1;

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h05, "P1: after LDA 9, A=0x05");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h00, "P1: after SUB 10, A=0x00");
        check1(dut.flags[0], 1'b1, "P1: ZF=1 after 5-5");

        step_once; step_once; step_once; step_once; step_once;
        check8({4'b0000, dut.pc_val}, 8'h06, "P1: PC=6 after JZ taken");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h2A, "P1: after 2nd LDA, A=0x2A (42)");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.out_val, 8'h2A, "P1: out_val=0x2A (42) after OUT");

        step_once; step_once; step_once;
        check1(dut.HLT, 1'b1, "P1: HLT asserted, machine halted");

        step_once; step_once; step_once;
        check8(dut.a_val, 8'h2A, "P1: A unchanged after halt (extra steps ignored)");
        check1(dut.HLT, 1'b1, "P1: HLT still asserted after extra steps");

        SW[13] = 0; 
        prog_write_byte(4'd0,  8'h09); 
        prog_write_byte(4'd1,  8'h1A); 
        prog_write_byte(4'd2,  8'h3B); 
        prog_write_byte(4'd3,  8'h46); 
        prog_write_byte(4'd6,  8'h0B); 
        prog_write_byte(4'd7,  8'hE0);
        prog_write_byte(4'd8,  8'hF0); 
        prog_write_byte(4'd9,  8'h07); 
        prog_write_byte(4'd10, 8'h08); 

        do_reset(); 

        SW[13] = 1; 

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h07, "P2: after LDA 9, A=0x07");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h0F, "P2: after ADD 10, A=0x0F (15)");
        check1(dut.flags[0], 1'b0, "P2: ZF=0 (15 != 0)");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.RAM0.mem[11], 8'h0F, "P2: RAM[11]=0x0F after STA (via debug read)");

        step_once; step_once; step_once; step_once; step_once;
        check8({4'b0000, dut.pc_val}, 8'h06, "P2: PC=6 after JMP");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h0F, "P2: after 2nd LDA, A=0x0F (15, read back from RAM)");

        step_once; step_once; step_once; step_once; step_once;
        check8(dut.out_val, 8'h0F, "P2: out_val=0x0F (15) after OUT");

        step_once; step_once; step_once;
        check1(dut.HLT, 1'b1, "P2: HLT asserted, machine halted");

        if (errors == 0)
            $display("SAP_TOP_TB: ALL TESTS PASSED");
        else
            $display("SAP_TOP_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
