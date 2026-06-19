// =====================================================================
// Testbench   : b_reg_tb
// Unit Under Test : b_reg.v
// -----------------------------------------------------------------------
// Stimulus:
//   1. Reset, confirm b_out = 0x00.
//   2. BI=1,EN=1 with bus_in=0x07; confirm b_out latches 0x07.
//   3. BI=0; confirm value holds.
//   4. BI=1,EN=0; confirm value does NOT change (gating).
//   5. BI=1,EN=1 with new value 0x80; confirm latch.
//
// Expected Waveform (b_reg_tb.vcd):
//   Same shape as a_reg_tb.vcd -- flat at reset, steps up on each
//   accepted BI+EN load, flat during BI=0 or EN=0 windows.
// =====================================================================
`timescale 1ns/1ps

module b_reg_tb;

    reg clk, reset, EN, BI;
    reg [7:0] bus_in;
    wire [7:0] b_out;
    integer errors = 0;

    b_reg UUT (
        .clk(clk), .reset(reset), .EN(EN), .BI(BI),
        .bus_in(bus_in), .b_out(b_out)
    );

    always #5 clk = ~clk;

    task check(input [7:0] expected, input [255:0] msg);
        begin
            if (b_out !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h time=%0t", msg, expected, b_out, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | b_out=%h time=%0t", msg, b_out, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("b_reg_tb.vcd");
        $dumpvars(0, b_reg_tb);

        clk = 0; reset = 1; EN = 0; BI = 0; bus_in = 8'h00;
        @(posedge clk); @(posedge clk);
        check(8'h00, "reset clears B");

        reset = 0; EN = 1; BI = 1; bus_in = 8'h07;
        @(posedge clk); #1; check(8'h07, "BI load 0x07");

        BI = 0; bus_in = 8'h55;
        @(posedge clk); #1; check(8'h07, "BI=0 holds value");

        BI = 1; EN = 0;
        @(posedge clk); #1; check(8'h07, "EN=0 blocks load despite BI=1");

        EN = 1;
        @(posedge clk); #1; check(8'h55, "EN=1 loads new value 0x55");

        if (errors == 0)
            $display("B_REG_TB: ALL TESTS PASSED");
        else
            $display("B_REG_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
