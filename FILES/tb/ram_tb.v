// =====================================================================
// Testbench   : ram_tb
// Unit Under Test : ram.v
// -----------------------------------------------------------------------
// Stimulus:
//   1. Program Mode (run_mode=0): write 0xAA to address 0x3 via
//      prog_write pulse; confirm ram_out reflects it when prog_addr=3.
//   2. Program Mode: write a second location (addr=0x7, data=0x55);
//      confirm both locations hold their distinct values.
//   3. Program Mode: change prog_addr WITHOUT a write pulse; confirm
//      ram_out simply follows the read address (no accidental write).
//   4. Switch to Run Mode (run_mode=1): confirm ram_out now reflects
//      mem[addr_run] (the previously programmed value at address 3).
//   5. Run Mode: RI=1,EN=1 with bus_in=0x99 at addr_run=3; confirm the
//      location is overwritten and ram_out updates.
//   6. Run Mode: RI=1,EN=0; confirm NO write occurs (gating).
//   7. Run Mode: RI=1,EN=1,reset=1; confirm NO write occurs (reset
//      blocks run-mode writes).
//   8. Confirm RAM contents are NOT cleared by reset (value from step
//      2 still readable afterward).
//
// Expected Waveform (ram_tb.vcd):
//   prog_write pulses are narrow (1 clk) one-shot pulses; ram_out
//   updates on the clock edge following each pulse.
//   run_mode transition switches ram_out's addressing source
//   instantly (combinational mux on addr_sel).
//   RI-driven writes in Run Mode only commit when EN=1 and reset=0.
// =====================================================================
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

        // ---- Program Mode writes ----
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

        // ---- Switch to Run Mode ----
        run_mode = 1; addr_run = 4'h3;
        #1; check(8'hAA, "Run Mode: addr_run=3 reads 0xAA programmed earlier");

        // ---- Run-mode write, EN=1 ----
        RI = 1; EN = 1; bus_in = 8'h99;
        @(posedge clk); #1;
        check(8'h99, "Run Mode write: addr_run=3 now reads 0x99");

        // ---- Run-mode write attempt with EN=0 (should be blocked) ----
        RI = 1; EN = 0; bus_in = 8'h11;
        @(posedge clk); #1;
        check(8'h99, "EN=0 blocks run-mode write (still 0x99)");

        // ---- Run-mode write attempt with reset=1 (should be blocked) ----
        RI = 1; EN = 1; reset = 1; bus_in = 8'h22;
        @(posedge clk); #1;
        check(8'h99, "reset=1 blocks run-mode write (still 0x99)");
        reset = 0; RI = 0;

        // ---- Confirm reset never clears RAM contents ----
        run_mode = 0; prog_addr = 4'h7;
        #1; check(8'h55, "RAM contents survive reset (addr7 still 0x55)");

        if (errors == 0)
            $display("RAM_TB: ALL TESTS PASSED");
        else
            $display("RAM_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
