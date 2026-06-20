`timescale 1ns/1ps

module pc_tb;

    reg clk, reset, EN, CE, LP;
    reg [7:0] bus_in;
    wire [3:0] pc_out;
    integer errors = 0;
    integer i;

    pc UUT (
        .clk(clk), .reset(reset), .EN(EN), .CE(CE), .LP(LP),
        .bus_in(bus_in), .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    task check(input [3:0] expected, input [255:0] msg);
        begin
            if (pc_out !== expected) begin
                $display("FAIL: %0s | expected=%0d actual=%0d time=%0t", msg, expected, pc_out, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | pc_out=%0d time=%0t", msg, pc_out, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);

        clk = 0; reset = 1; EN = 0; CE = 0; LP = 0; bus_in = 8'h00;
        @(posedge clk); @(posedge clk);
        check(4'd0, "reset clears PC");

        reset = 0; EN = 1; CE = 1;
        @(posedge clk); #1; check(4'd1, "increment #1");
        @(posedge clk); #1; check(4'd2, "increment #2");
        @(posedge clk); #1; check(4'd3, "increment #3");

        CE = 0; LP = 1; bus_in = 8'h0A;
        @(posedge clk); #1; check(4'd10, "jump load via LP (0x0A)");

        LP = 0; CE = 1; EN = 0;
        @(posedge clk); #1; check(4'd10, "EN=0 holds value (no count)");
        @(posedge clk); #1; check(4'd10, "EN=0 still holding");

        EN = 1;
        @(posedge clk); #1; check(4'd11, "counting resumes when EN=1");

        reset = 1; @(posedge clk); #1; reset = 0;
        check(4'd0, "second reset clears PC");

        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk); #1;
        end
        check(4'd0, "4-bit wraparound after 16 increments (15->0)");

        if (errors == 0)
            $display("PC_TB: ALL TESTS PASSED");
        else
            $display("PC_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
