// =====================================================================
// Module      : ir
// Purpose     : 8-bit Instruction Register. Latches the instruction
//               byte fetched from RAM and splits it into the 4-bit
//               opcode field and 4-bit operand (address) field.
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock.
//   reset    : Synchronous, active-high. Clears IR to 0x00.
//   EN       : Global CPU clock-enable ("tick").
//   II       : Instruction-register-In control signal. When II=1
//              (and EN=1), ir_out <= bus_in (captures fetched byte).
//   bus_in   : 8-bit shared system bus.
//   ir_out   : Full latched instruction byte (exposed for test/debug).
//   opcode   : ir_out[7:4] -- combinationally derived, feeds controller.
//   operand  : ir_out[3:0] -- combinationally derived, the address
//              field. Placed on the bus by bus_mux.v whenever IO=1.
// =====================================================================
module ir (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        II,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  ir_out,
    output wire [3:0]  opcode,
    output wire [3:0]  operand
);

    always @(posedge clk) begin
        if (reset)
            ir_out <= 8'h00;
        else if (EN && II)
            ir_out <= bus_in;
    end

    assign opcode  = ir_out[7:4];
    assign operand = ir_out[3:0];

endmodule
