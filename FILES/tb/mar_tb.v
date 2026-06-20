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
