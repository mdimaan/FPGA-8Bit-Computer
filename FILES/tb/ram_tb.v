`timescale 1ns/1ps

module ram_tb;

    reg clk, reset, EN, run_mode, RI, prog_write;
    reg [3:0] addr_run, prog_addr;
    reg [7:0] bus_in, prog_data;
    wire [7:0] ram_out;
    integer errors = 0;

    ram UUT (
        .clk(clk), .reset(reset), .EN(EN), .run_mode(run_mode),
        .addr_run(addr_run), .RI(RI), .bus_in(bus_in),
        .prog_addr(prog_addr), .prog_data(prog_data), .prog_write(prog_write),
        .ram_out(ram_out)
    );

    always #5 clk = ~clk;

    task check(input [7:0] expected, input [255:0] msg);
        begin
            if (ram_out !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h time=%0t", msg, expected, ram_out, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | ram_out=%h time=%0t", msg, ram_out, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("ram_tb.vcd");
        $dumpvars(0, ram_tb);

        clk = 0; reset = 0; EN = 0; run_mode = 0; RI = 0; prog_write = 0;
        addr_run = 0; prog_addr = 0; bus_in = 0; prog_data = 0;

        prog_addr = 4'h3; prog_data = 8'hAA; prog_write = 1;
        @(posedge clk); #1;
        prog_write = 0;
        check(8'hAA, "Program Mode: addr3 reads back 0xAA after write");

        prog_addr = 4'h7; prog_data = 8'h55; prog_write = 1;
        @(posedge clk); #1;
        prog_write = 0;
        check(8'h55, "Program Mode: addr7 reads back 0x55 after write");

        prog_addr = 4'h3;
        #1; check(8'hAA, "Program Mode: addr3 still holds 0xAA (no write pulse)");

        run_mode = 1; addr_run = 4'h3;
        #1; check(8'hAA, "Run Mode: addr_run=3 reads 0xAA programmed earlier");

        RI = 1; EN = 1; bus_in = 8'h99;
        @(posedge clk); #1;
        check(8'h99, "Run Mode write: addr_run=3 now reads 0x99");

        RI = 1; EN = 0; bus_in = 8'h11;
        @(posedge clk); #1;
        check(8'h99, "EN=0 blocks run-mode write (still 0x99)");

        RI = 1; EN = 1; reset = 1; bus_in = 8'h22;
        @(posedge clk); #1;
        check(8'h99, "reset=1 blocks run-mode write (still 0x99)");
        reset = 0; RI = 0;

        run_mode = 0; prog_addr = 4'h7;
        #1; check(8'h55, "RAM contents survive reset (addr7 still 0x55)");

        if (errors == 0)
            $display("RAM_TB: ALL TESTS PASSED");
        else
            $display("RAM_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
