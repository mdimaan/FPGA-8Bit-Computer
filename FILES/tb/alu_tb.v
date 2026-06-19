// =====================================================================
// Testbench   : alu_tb
// Unit Under Test : alu.v  (purely combinational -- no clock needed)
// -----------------------------------------------------------------------
// Stimulus:
//   1. ADD: 0x05 + 0x03 = 0x08, ZF=0, CF=0.
//   2. ADD with carry-out: 0xFF + 0x02 = 0x01 (mod 256), CF=1, ZF=0.
//   3. ADD producing zero: 0x00 + 0x00 = 0x00, ZF=1, CF=0.
//   4. SUB: 0x09 - 0x04 = 0x05, ZF=0, CF=1 (no borrow, a>=b).
//   5. SUB producing zero: 0x07 - 0x07 = 0x00, ZF=1, CF=1 (no borrow).
//   6. SUB with borrow: 0x03 - 0x05 = 0xFE (two's complement wrap),
//      CF=0 (borrow occurred), ZF=0.
//
// Expected Waveform (alu_tb.vcd):
//   Purely combinational -- result/zero_flag/carry_flag change
//   immediately (same simulation time step) whenever a_in/b_in/SU
//   change. No clock edges are involved in this testbench at all.
// =====================================================================
`timescale 1ns/1ps

module alu_tb;

    reg [7:0] a_in, b_in;
    reg SU;
    wire [7:0] result;
    wire zero_flag, carry_flag;
    integer errors = 0;

    alu UUT (
        .a_in(a_in), .b_in(b_in), .SU(SU),
        .result(result), .zero_flag(zero_flag), .carry_flag(carry_flag)
    );

    task check(input [7:0] exp_r, input exp_z, input exp_c, input [255:0] msg);
        begin
            #1;
            if (result !== exp_r || zero_flag !== exp_z || carry_flag !== exp_c) begin
                $display("FAIL: %0s | expected result=%h ZF=%b CF=%b actual result=%h ZF=%b CF=%b",
                          msg, exp_r, exp_z, exp_c, result, zero_flag, carry_flag);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | result=%h ZF=%b CF=%b", msg, result, zero_flag, carry_flag);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        a_in = 8'h05; b_in = 8'h03; SU = 0;
        check(8'h08, 1'b0, 1'b0, "ADD 0x05+0x03=0x08");

        a_in = 8'hFF; b_in = 8'h02; SU = 0;
        check(8'h01, 1'b0, 1'b1, "ADD 0xFF+0x02=0x01 carry-out");

        a_in = 8'h00; b_in = 8'h00; SU = 0;
        check(8'h00, 1'b1, 1'b0, "ADD 0x00+0x00=0x00 zero");

        a_in = 8'h09; b_in = 8'h04; SU = 1;
        check(8'h05, 1'b0, 1'b1, "SUB 0x09-0x04=0x05 no borrow");

        a_in = 8'h07; b_in = 8'h07; SU = 1;
        check(8'h00, 1'b1, 1'b1, "SUB 0x07-0x07=0x00 zero, no borrow");

        a_in = 8'h03; b_in = 8'h05; SU = 1;
        check(8'hFE, 1'b0, 1'b0, "SUB 0x03-0x05=0xFE borrow occurred");

        if (errors == 0)
            $display("ALU_TB: ALL TESTS PASSED");
        else
            $display("ALU_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
