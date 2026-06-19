// =====================================================================
// Module      : b_reg
// Purpose     : 8-bit B Register. Holds the second ALU operand (the
//               value fetched from RAM during ADD/SUB execution).
//               B has no output-enable -- it never drives the shared
//               bus; it feeds the ALU directly (matches classic SAP-1).
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock.
//   reset    : Synchronous, active-high. Clears B to 0x00.
//   EN       : Global CPU clock-enable ("tick").
//   BI       : B-register-In control signal. When BI=1 (and EN=1),
//              b_out <= bus_in.
//   bus_in   : 8-bit shared system bus.
//   b_out    : Current B register value, fed directly into alu.v.
// =====================================================================
module b_reg (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        BI,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  b_out
);

    always @(posedge clk) begin
        if (reset)
            b_out <= 8'h00;
        else if (EN && BI)
            b_out <= bus_in;
    end

endmodule
