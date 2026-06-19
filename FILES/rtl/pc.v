// =====================================================================
// Module      : pc
// Purpose     : 4-bit Program Counter for the SAP-1 style CPU.
//               Holds the address of the next instruction to fetch.
//               Can be incremented (normal fetch sequencing) or
//               loaded directly from the bus (JMP / JZ execution).
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock (CLK100MHZ, free running).
//   reset    : Synchronous, active-high. Forces PC back to 0000.
//   EN       : Global CPU clock-enable ("tick"). The PC only changes
//              state on a clock edge where EN = 1. This is what lets
//              the whole machine be advanced manually one T-state at
//              a time using the STEP switch (see sap_top.v).
//   CE       : Count Enable control signal from controller.v.
//              When CE=1 (and EN=1), PC <= PC + 1.
//   LP       : Load PC control signal (asserted during JMP/JZ).
//              When LP=1 (and EN=1), PC <= bus_in[3:0]. LP has
//              priority over CE (the two are never asserted together
//              by the controller, but priority is defined for safety).
//   bus_in   : The 8-bit shared system bus. Only the lower nibble is
//              used as the jump target address.
//   pc_out   : Current 4-bit program counter value. Driven onto the
//              bus by bus_mux.v whenever CO=1.
// =====================================================================
module pc (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        CE,
    input  wire        LP,
    input  wire [7:0]  bus_in,
    output reg  [3:0]  pc_out
);

    always @(posedge clk) begin
        if (reset)
            pc_out <= 4'b0000;
        else if (EN) begin
            if (LP)
                pc_out <= bus_in[3:0];
            else if (CE)
                pc_out <= pc_out + 4'b0001;
        end
    end

endmodule
