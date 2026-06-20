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
