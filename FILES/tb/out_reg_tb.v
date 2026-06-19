// =====================================================================
// Testbench   : out_reg_tb
// Unit Under Test : out_reg.v
// -----------------------------------------------------------------------
// Stimulus:
//   1. Reset, confirm out_val = 0x00.
//   2. OI=1,EN=1 with bus_in=0x42; confirm out_val latches 0x42.
//   3. OI=0; confirm value holds (this models A changing after OUT
//      without disturbing the displayed value).
//   4. OI=1,EN=0; confirm value does NOT change (gating).
//   5. OI=1,EN=1 with new value 0xFF; confirm latch.
//
// Expected Waveform (out_reg_tb.vcd):
//   Flat at 0x00 through reset, single step to 0x42 on the OI+EN
//   load, flat thereafter until the next accepted load to 0xFF.
// =====================================================================
`timescale 1ns/1ps

module out_reg_tb;

    reg clk, reset, EN, OI;
    reg [7:0] bus_in;
    wire [7:0] out_val;
    integer errors = 0;

    out_reg UUT (
        .clk(clk), .reset(reset), .EN(EN), .OI(OI),
        .bus_in(bus_in), .out_val(out_val)
    );

    always #5 clk = ~clk;

    task check(input [7:0] expected, input [255:0] msg);
        begin
            if (out_val !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h time=%0t", msg, expected, out_val, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | out_val=%h time=%0t", msg, out_val, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("out_reg_tb.vcd");
        $dumpvars(0, out_reg_tb);

        clk = 0; reset = 1; EN = 0; OI = 0; bus_in = 8'h00;
        @(posedge clk); @(posedge clk);
        check(8'h00, "reset clears OUT");

        reset = 0; EN = 1; OI = 1; bus_in = 8'h42;
        @(posedge clk); #1; check(8'h42, "OI load 0x42");

        OI = 0; bus_in = 8'h11;
        @(posedge clk); #1; check(8'h42, "OI=0 holds value (A may change freely)");

        OI = 1; EN = 0;
        @(posedge clk); #1; check(8'h42, "EN=0 blocks load despite OI=1");

        EN = 1; bus_in = 8'hFF;
        @(posedge clk); #1; check(8'hFF, "EN=1 loads new value 0xFF");

        if (errors == 0)
            $display("OUT_REG_TB: ALL TESTS PASSED");
        else
            $display("OUT_REG_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
