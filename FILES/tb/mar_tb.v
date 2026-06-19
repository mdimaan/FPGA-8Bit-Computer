// =====================================================================
// Testbench   : mar_tb
// Unit Under Test : mar.v
// -----------------------------------------------------------------------
// Stimulus:
//   1. Reset, confirm mar_out = 0.
//   2. Drive bus_in=0x05 with MI=1, EN=1; confirm mar_out latches 5.
//   3. Change bus_in without asserting MI; confirm mar_out holds (5).
//   4. Assert MI again with EN=0; confirm mar_out does NOT change
//      (manual-step gating).
//   5. Assert MI with EN=1 and a new bus value; confirm it latches.
//
// Expected Waveform (mar_tb.vcd):
//   reset high -> mar_out flat 0.
//   MI pulse with bus_in=5 -> mar_out steps to 5 on next posedge clk.
//   bus_in changes while MI=0 -> mar_out unaffected (flat line at 5).
//   MI=1,EN=0 -> mar_out still flat (gating proven).
//   MI=1,EN=1 -> mar_out steps to new value.
// =====================================================================
`timescale 1ns/1ps

module mar_tb;

    reg clk, reset, EN, MI;
    reg [7:0] bus_in;
    wire [3:0] mar_out;
    integer errors = 0;

    mar UUT (
        .clk(clk), .reset(reset), .EN(EN), .MI(MI),
        .bus_in(bus_in), .mar_out(mar_out)
    );

    always #5 clk = ~clk;

    task check(input [3:0] expected, input [255:0] msg);
        begin
            if (mar_out !== expected) begin
                $display("FAIL: %0s | expected=%0d actual=%0d time=%0t", msg, expected, mar_out, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | mar_out=%0d time=%0t", msg, mar_out, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("mar_tb.vcd");
        $dumpvars(0, mar_tb);

        clk = 0; reset = 1; EN = 0; MI = 0; bus_in = 8'h00;
        @(posedge clk); @(posedge clk);
        check(4'd0, "reset clears MAR");

        reset = 0; EN = 1; MI = 1; bus_in = 8'h05;
        @(posedge clk); #1; check(4'd5, "MI load 0x05");

        MI = 0; bus_in = 8'h0F;
        @(posedge clk); #1; check(4'd5, "MI=0 holds previous value");

        MI = 1; EN = 0;
        @(posedge clk); #1; check(4'd5, "EN=0 blocks load despite MI=1");

        EN = 1;
        @(posedge clk); #1; check(4'd15, "EN=1,MI=1 loads new value 0x0F");

        if (errors == 0)
            $display("MAR_TB: ALL TESTS PASSED");
        else
            $display("MAR_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
