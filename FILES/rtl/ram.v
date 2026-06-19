// =====================================================================
// Module      : ram
// Purpose     : 16 x 8 main memory with two access modes:
//                 Program Mode (run_mode=0): address/data/write come
//                 from the front-panel switches (manual loading).
//                 Run Mode (run_mode=1): address comes from MAR,
//                 writes come from the bus under RI, reads always
//                 flow out to ram_out (gated onto the bus by RO via
//                 bus_mux.v).
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk         : System clock.
//   reset       : Synchronous reset. NOTE: RAM contents are
//                 intentionally NOT cleared on reset, so a program
//                 loaded by hand survives a CPU reset/restart.
//   EN          : Global CPU clock-enable ("tick"). Gates Run-Mode
//                 writes only -- Program-Mode writes are driven by
//                 their own one-shot pulse and are independent of EN.
//   run_mode    : 1 = Run Mode (CPU-controlled), 0 = Program Mode.
//   addr_run    : 4-bit address from mar.v (used when run_mode=1).
//   RI          : Run-mode write enable (bus -> RAM at addr_run).
//   bus_in      : 8-bit shared system bus (Run-mode write data).
//   prog_addr   : 4-bit address from switches SW[3:0] (Program Mode).
//   prog_data   : 8-bit data from switches SW[11:4] (Program Mode).
//   prog_write  : One-shot write pulse, already edge-detected and
//                 synchronized at the top level from SW[12] (WRITE).
//   ram_out     : Combinational read data at the currently selected
//                 address (addr_run in Run Mode, prog_addr in Program
//                 Mode) -- this lets the 7-seg display show RAM
//                 contents for verification while programming.
// =====================================================================
module ram (
    input  wire        clk,
    input  wire        reset,
    input  wire        EN,
    input  wire         run_mode,
    input  wire [3:0]   addr_run,
    input  wire         RI,
    input  wire [7:0]   bus_in,
    input  wire [3:0]   prog_addr,
    input  wire [7:0]   prog_data,
    input  wire         prog_write,
    output wire [7:0]   ram_out
);

    reg [7:0] mem [0:15];
    integer i;

    wire [3:0] addr_sel = run_mode ? addr_run : prog_addr;
    assign ram_out = mem[addr_sel];

    always @(posedge clk) begin
        if (run_mode) begin
            // Run-mode writes are gated by reset so the CPU cannot
            // scribble into memory while it is being held in reset.
            if (!reset && EN && RI)
                mem[addr_run] <= bus_in;
        end
        else begin
            // Program-mode writes work regardless of the reset switch
            // so a program can be (re)loaded at any time before RUN.
            if (prog_write)
                mem[prog_addr] <= prog_data;
        end
        // RAM contents are never cleared by reset itself -- only the
        // explicit write paths above ever change mem[].
    end

    // Simulation-only initialization so waveforms show 00 instead of
    // X before any switch programming takes place. Vivado synthesis
    // ignores this initial block's effect on real BRAM/LUTRAM unless
    // device init values are desired; it is harmless either way.
    initial begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 8'h00;
    end

endmodule
