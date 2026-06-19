// =====================================================================
// Module      : sap_top
// Purpose     : Top-level integration of the SAP-1 style 8-bit
//               computer for the Boolean Board (Spartan-7
//               XC7S50-CSGA324-1). Wires together every datapath and
//               control module, implements switch synchronization /
//               edge detection, the manual-step clocking scheme, and
//               drives the seven-segment display.
// -----------------------------------------------------------------------
// Switch map (matches the project specification exactly):
//   SW[3:0]   = RAM Address    (Program Mode)
//   SW[11:4]  = RAM Data       (Program Mode)
//   SW[12]    = WRITE          (one-shot: commits Address/Data to RAM)
//   SW[13]    = RUN            (1 = Run Mode, 0 = Program Mode)
//   SW[14]    = RESET          (synchronous CPU reset)
//   SW[15]    = STEP           (one-shot: manually advances one tick)
//
// Clocking philosophy (see DOCUMENTATION.md "Manual Stepping" for the
// full rationale):
//   * The CPU's true clock is always CLK100MHZ -- there is no gated
//     clock anywhere, which keeps every register FPGA/Vivado-friendly.
//   * What "ticks" the CPU forward by exactly one T-state is a
//     single-cycle clock-ENABLE pulse, EN, generated here:
//       - In Program Mode (RUN=0): EN is held low. The CPU is frozen
//         while the operator loads RAM by hand.
//       - In Run Mode (RUN=1): EN = auto_tick (~2 Hz, so execution is
//         visible on the display) OR'd with a manual one-shot pulse
//         from the STEP switch, so the operator can also single-step
//         through T-states on demand for debugging.
//   * RAM programming writes (prog_write) are entirely independent of
//     EN -- they fire directly off a debounced/edge-detected pulse
//     from the WRITE switch any time RUN=0.
//   * RESET is double-flop synchronized to CLK100MHZ before use, as
//     is standard practice for any asynchronous switch input.
// -----------------------------------------------------------------------
// Display: the seven-segment display always shows out_val (the
// Output Register, updated by the OUT instruction) while in Run Mode,
// and shows the live RAM contents at the address currently selected
// by SW[3:0] while in Program Mode, so the operator can verify what
// was written.
// =====================================================================
module sap_top (
    input  wire        CLK100MHZ,
    input  wire [15:0] SW,
    output wire [6:0]  SEG,
    output wire [3:0]  AN
);

    // ------------------------------------------------------------------
    // Switch field decode
    // ------------------------------------------------------------------
    wire [3:0] sw_addr  = SW[3:0];
    wire [7:0] sw_data  = SW[11:4];
    wire       sw_write = SW[12];
    wire       sw_run   = SW[13];
    wire       sw_reset = SW[14];
    wire       sw_step  = SW[15];

    // ------------------------------------------------------------------
    // Switch synchronization (2-flop) + one-shot edge detection
    // ------------------------------------------------------------------
    reg [1:0] write_sync, step_sync, reset_sync;

    always @(posedge CLK100MHZ) begin
        write_sync <= {write_sync[0], sw_write};
        step_sync  <= {step_sync[0],  sw_step};
        reset_sync <= {reset_sync[0], sw_reset};
    end

    wire prog_write_pulse = write_sync[0] & ~write_sync[1];
    wire step_edge_pulse  = step_sync[0]  & ~step_sync[1];
    wire reset            = reset_sync[1];

    // ------------------------------------------------------------------
    // ~2 Hz auto-tick generator for visible automatic execution in
    // Run Mode (100,000,000 / 50,000,000 = 2 Hz toggle rate)
    // ------------------------------------------------------------------
    reg [25:0] clk_div;
    wire auto_tick = (clk_div == 26'd49_999_999);

    always @(posedge CLK100MHZ) begin
        if (reset || auto_tick)
            clk_div <= 26'd0;
        else
            clk_div <= clk_div + 26'd1;
    end

    wire run_mode = sw_run;
    wire EN       = run_mode & (auto_tick | step_edge_pulse);

    // ------------------------------------------------------------------
    // Internal bus and inter-module signals
    // ------------------------------------------------------------------
    wire [7:0] bus;
    wire [3:0] pc_val;
    wire [3:0] mar_val;
    wire [7:0] ram_val;
    wire [7:0] ir_full;
    wire [3:0] opcode, operand;
    wire [7:0] a_val, b_val, alu_val, out_val;
    wire       alu_zero, alu_carry;
    wire [1:0] flags;
    wire [4:0] step;

    wire CO, CE, MI, RO, RI, II, IO, AI, AO, BI, OI, LP, SU, EO, FI, HLT;

    // ------------------------------------------------------------------
    // Module instances
    // ------------------------------------------------------------------
    pc PC0 (
        .clk     (CLK100MHZ),
        .reset   (reset),
        .EN      (EN),
        .CE      (CE),
        .LP      (LP),
        .bus_in  (bus),
        .pc_out  (pc_val)
    );

    mar MAR0 (
        .clk     (CLK100MHZ),
        .reset   (reset),
        .EN      (EN),
        .MI      (MI),
        .bus_in  (bus),
        .mar_out (mar_val)
    );

    ram RAM0 (
        .clk        (CLK100MHZ),
        .reset      (reset),
        .EN         (EN),
        .run_mode   (run_mode),
        .addr_run   (mar_val),
        .RI         (RI),
        .bus_in     (bus),
        .prog_addr  (sw_addr),
        .prog_data  (sw_data),
        .prog_write (prog_write_pulse),
        .ram_out    (ram_val)
    );

    ir IR0 (
        .clk     (CLK100MHZ),
        .reset   (reset),
        .EN      (EN),
        .II      (II),
        .bus_in  (bus),
        .ir_out  (ir_full),
        .opcode  (opcode),
        .operand (operand)
    );

    a_reg A0 (
        .clk     (CLK100MHZ),
        .reset   (reset),
        .EN      (EN),
        .AI      (AI),
        .bus_in  (bus),
        .a_out   (a_val)
    );

    b_reg B0 (
        .clk     (CLK100MHZ),
        .reset   (reset),
        .EN      (EN),
        .BI      (BI),
        .bus_in  (bus),
        .b_out   (b_val)
    );

    alu ALU0 (
        .a_in       (a_val),
        .b_in       (b_val),
        .SU         (SU),
        .result     (alu_val),
        .zero_flag  (alu_zero),
        .carry_flag (alu_carry)
    );

    flag_reg FLAGS0 (
        .clk      (CLK100MHZ),
        .reset    (reset),
        .EN       (EN),
        .FI       (FI),
        .zero_in  (alu_zero),
        .carry_in (alu_carry),
        .flags    (flags)
    );

    out_reg OUT0 (
        .clk     (CLK100MHZ),
        .reset   (reset),
        .EN      (EN),
        .OI      (OI),
        .bus_in  (bus),
        .out_val (out_val)
    );

    step_counter STEP0 (
        .clk   (CLK100MHZ),
        .reset (reset),
        .EN    (EN),
        .hlt   (HLT),
        .step  (step)
    );

    controller CTRL0 (
        .step      (step),
        .opcode    (opcode),
        .zero_flag (flags[0]),
        .CO (CO), .CE (CE), .MI (MI), .RO (RO), .RI (RI),
        .II (II), .IO (IO), .AI (AI), .AO (AO), .BI (BI),
        .OI (OI), .LP (LP), .SU (SU), .EO (EO), .FI (FI),
        .HLT (HLT)
    );

    bus_mux BUSMUX0 (
        .CO         (CO),
        .RO         (RO),
        .AO         (AO),
        .EO         (EO),
        .IO         (IO),
        .pc_val     (pc_val),
        .ram_val    (ram_val),
        .a_val      (a_val),
        .alu_val    (alu_val),
        .ir_operand (operand),
        .bus_out    (bus)
    );

    // ------------------------------------------------------------------
    // Seven-segment display
    // ------------------------------------------------------------------
    seven_seg DISP0 (
        .clk   (CLK100MHZ),
        .reset (reset),
        .value (run_mode ? out_val : ram_val),
        .seg   (SEG),
        .an    (AN)
    );

endmodule
