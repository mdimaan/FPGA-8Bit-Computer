// =====================================================================
// Testbench   : step_counter_tb
// Unit Under Test : step_counter.v
// -----------------------------------------------------------------------
// Stimulus:
//   1. Reset, confirm step = T1 (5'b00001).
//   2. EN=1, hlt=0: step through one full cycle T1->T2->T3->T4->T5->T1,
//      checking each state in order.
//   3. EN=0: confirm step HOLDS (manual single-stepping gating).
//   4. EN=1, hlt=1: confirm step FREEZES at its current value even
//      though EN pulses (models the permanent HLT condition).
//   5. Reset again: confirm step returns to T1 even while hlt=1.
//
// Expected Waveform (step_counter_tb.vcd):
//   step one-hot value cycles 00001->00010->00100->01000->10000->00001
//   each clock while EN=1,hlt=0.
//   Flat line (no change) during the EN=0 window.
//   Flat line again during the hlt=1 window even with EN=1.
//   Drops back to 00001 the instant reset is asserted.
// =====================================================================
`timescale 1ns/1ps

module step_counter_tb;

    reg clk, reset, EN, hlt;
    wire [4:0] step;
    integer errors = 0;

    localparam T1 = 5'b00001, T2 = 5'b00010, T3 = 5'b00100,
               T4 = 5'b01000, T5 = 5'b10000;

    step_counter UUT (
        .clk(clk), .reset(reset), .EN(EN), .hlt(hlt), .step(step)
    );

    always #5 clk = ~clk;

    task check(input [4:0] expected, input [255:0] msg);
        begin
            if (step !== expected) begin
                $display("FAIL: %0s | expected=%b actual=%b time=%0t", msg, expected, step, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | step=%b time=%0t", msg, step, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("step_counter_tb.vcd");
        $dumpvars(0, step_counter_tb);

        clk = 0; reset = 1; EN = 0; hlt = 0;
        @(posedge clk); @(posedge clk);
        check(T1, "reset forces T1");

        reset = 0; EN = 1;
        @(posedge clk); #1; check(T2, "T1->T2");
        @(posedge clk); #1; check(T3, "T2->T3");
        @(posedge clk); #1; check(T4, "T3->T4");
        @(posedge clk); #1; check(T5, "T4->T5");
        @(posedge clk); #1; check(T1, "T5->T1 (wrap)");

        EN = 0;
        @(posedge clk); #1; check(T1, "EN=0 holds at T1");
        @(posedge clk); #1; check(T1, "EN=0 still holds at T1");

        EN = 1;
        @(posedge clk); #1; check(T2, "EN=1 resumes T1->T2");

        hlt = 1;
        @(posedge clk); #1; check(T2, "hlt=1 freezes at T2");
        @(posedge clk); #1; check(T2, "hlt=1 still frozen at T2");
        @(posedge clk); #1; check(T2, "hlt=1 still frozen at T2 (cycle 3)");

        reset = 1;
        @(posedge clk); #1; check(T1, "reset overrides hlt, forces T1");

        if (errors == 0)
            $display("STEP_COUNTER_TB: ALL TESTS PASSED");
        else
            $display("STEP_COUNTER_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
