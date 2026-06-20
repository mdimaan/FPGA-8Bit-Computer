module sap_top (
    input  wire        CLK100MHZ,
    input  wire [15:0] SW,
    input  wire        BTN_CLR,   
    output wire [6:0]  SEG,
    output wire [3:0]  AN
);

    wire [3:0] sw_addr  = SW[3:0];
    wire [7:0] sw_data  = SW[11:4];
    wire       sw_write = SW[12];
    wire       sw_run   = SW[13];
    wire       sw_reset = SW[14];
   
    reg [1:0] write_sync, reset_sync, run_sync; 
    reg [1:0] clr_sync;                                    

    always @(posedge CLK100MHZ) begin
        write_sync <= {write_sync[0], sw_write};
        reset_sync <= {reset_sync[0], sw_reset};
        run_sync   <= {run_sync[0],   sw_run};   
        clr_sync   <= {clr_sync[0],   BTN_CLR};  
    end

    wire prog_write_pulse = write_sync[0] & ~write_sync[1];
    wire full_clear = clr_sync[1];
    wire run_mode   = run_sync[1];                    
    wire run_rising = run_sync[0] & ~run_sync[1];    
    wire reset = reset_sync[1] | run_rising | full_clear;
    reg [25:0] clk_div;
    wire auto_tick = (clk_div == 26'd49_999_999);

    always @(posedge CLK100MHZ) begin
        if (reset || auto_tick)
            clk_div <= 26'd0;
        else
            clk_div <= clk_div + 26'd1;
    end

    wire EN = run_mode & auto_tick;
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
        .clear_all  (full_clear),  
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

    seven_seg DISP0 (
        .clk   (CLK100MHZ),
        .reset (reset),
        .value (run_mode ? out_val : ram_val),
        .seg   (SEG),
        .an    (AN)
    );

endmodule
