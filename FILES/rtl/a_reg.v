// =====================================================================
// Module      : a_reg
// Purpose     : 8-bit Accumulator (A Register). Holds the primary
//               operand/result for ALU operations and OUT.
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock.
//   reset    : Synchronous, active-high. Clears A to 0x00.
//   EN       : Global CPU clock-enable ("tick").
//   AI       : A-register-In control signal. When AI=1 (and EN=1),
//              a_out <= bus_in.
//   bus_in   : 8-bit shared system bus.
//   a_out    : Current accumulator value. Placed on the bus by
//              bus_mux.v whenever AO=1, and fed directly into alu.v.
// =====================================================================
module a_reg (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        AI,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  a_out
);

    always @(posedge clk) begin
        if (reset)
            a_out <= 8'h00;
        else if (EN && AI)
            a_out <= bus_in;
    end

endmodule
