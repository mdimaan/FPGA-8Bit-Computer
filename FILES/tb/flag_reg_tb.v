// =====================================================================
// Testbench   : flag_reg_tb
// Unit Under Test : flag_reg.v
// -----------------------------------------------------------------------
// Stimulus:
//   1. Reset, confirm flags = 2'b00.
//   2. FI=1,EN=1, zero_in=1,carry_in=0; confirm flags = 2'b01 (ZF=1).
//   3. FI=0; change zero_in/carry_in; confirm flags HOLD (latched).
//   4. FI=1,EN=1, zero_in=0,carry_in=1; confirm flags = 2'b10 (CF=1).
//   5. FI=1,EN=0; confirm flags do NOT change (gating).
//
// Expected Waveform (flag_reg_tb.vcd):
//   flags flat 00 through reset.
//   Step to 01 on first FI+EN capture (ZF=1,CF=0).
//   Flat at 01 while FI=0 even though zero_in/carry_in toggle.
//   Step to 10 on next FI+EN capture (ZF=0,CF=1).
//   Flat at 10 during EN=0 window despite FI=1.
// =====================================================================
`timescale 1ns/1ps

module flag_reg_tb;

    reg clk, reset, EN, FI;
    reg zero_in, carry_in;
    wire [1:0] flags;
    integer errors = 0;

    flag_reg UUT (
        .clk(clk), .reset(reset), .EN(EN), .FI(FI),
        .zero_in(zero_in), .carry_in(carry_in), .flags(flags)
    );

    always #5 clk = ~clk;

    task check(input [1:0] expected, input [255:0] msg);
        begin
            if (flags !== expected) begin
                $display("FAIL: %0s | expected=%b actual=%b time=%0t", msg, expected, flags, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | flags=%b time=%0t", msg, flags, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("flag_reg_tb.vcd");
        $dumpvars(0, flag_reg_tb);

        clk = 0; reset = 1; EN = 0; FI = 0; zero_in = 0; carry_in = 0;
        @(posedge clk); @(posedge clk);
        check(2'b00, "reset clears flags");

        reset = 0; EN = 1; FI = 1; zero_in = 1; carry_in = 0;
        @(posedge clk); #1; check(2'b01, "capture ZF=1,CF=0");

        FI = 0; zero_in = 0; carry_in = 1; // change inputs, should not matter
        @(posedge clk); #1; check(2'b01, "FI=0 holds latched flags");

        FI = 1; EN = 1; zero_in = 0; carry_in = 1;
        @(posedge clk); #1; check(2'b10, "capture ZF=0,CF=1");

        EN = 0; zero_in = 1; carry_in = 1;
        @(posedge clk); #1; check(2'b10, "EN=0 blocks capture despite FI=1");

        if (errors == 0)
            $display("FLAG_REG_TB: ALL TESTS PASSED");
        else
            $display("FLAG_REG_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
