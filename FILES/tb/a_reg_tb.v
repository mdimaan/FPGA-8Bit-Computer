`timescale 1ns/1ps

module a_reg_tb;

    reg clk, reset, EN, AI;
    reg [7:0] bus_in;
    wire [7:0] a_out;
    integer errors = 0;

    a_reg UUT (
        .clk(clk), .reset(reset), .EN(EN), .AI(AI),
        .bus_in(bus_in), .a_out(a_out)
    );

    always #5 clk = ~clk;

    task check(input [7:0] expected, input [255:0] msg);
        begin
            if (a_out !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h time=%0t", msg, expected, a_out, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | a_out=%h time=%0t", msg, a_out, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("a_reg_tb.vcd");
        $dumpvars(0, a_reg_tb);

        clk = 0; reset = 1; EN = 0; AI = 0; bus_in = 8'h00;
        @(posedge clk); @(posedge clk);
        check(8'h00, "reset clears A");

        reset = 0; EN = 1; AI = 1; bus_in = 8'h3C;
        @(posedge clk); #1; check(8'h3C, "AI load 0x3C");

        AI = 0; bus_in = 8'h99;
        @(posedge clk); #1; check(8'h3C, "AI=0 holds value");

        AI = 1; EN = 0;
        @(posedge clk); #1; check(8'h3C, "EN=0 blocks load despite AI=1");

        EN = 1;
        @(posedge clk); #1; check(8'h99, "EN=1 loads new value 0x99");

        if (errors == 0)
            $display("A_REG_TB: ALL TESTS PASSED");
        else
            $display("A_REG_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
