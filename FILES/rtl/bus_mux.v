// =====================================================================
// Module      : bus_mux
// Purpose     : Implements the shared 8-bit system bus using an
//               explicit multiplexer (no tri-state logic, as required
//               for clean FPGA synthesis). Selects exactly one source
//               to drive the bus based on the active output-enable
//               control signal. The controller guarantees that at
//               most one of CO/RO/AO/EO/IO is ever asserted in a
//               given T-state, so the if/else-if priority chain below
//               never has to arbitrate between two real sources.
// -----------------------------------------------------------------------
// Signal Explanation:
//   CO          : PC Output enable        -> bus = {4'b0, pc_val}
//   RO          : RAM Output enable        -> bus = ram_val
//   AO          : A register Output enable -> bus = a_val
//   EO          : ALU Output enable        -> bus = alu_val
//   IO          : IR operand Output enable -> bus = {4'b0, ir_operand}
//   pc_val      : 4-bit program counter value (zero-extended to 8 bits).
//   ram_val     : 8-bit RAM read data.
//   a_val       : 8-bit accumulator value.
//   alu_val     : 8-bit ALU result.
//   ir_operand  : 4-bit operand field of the instruction register
//                 (zero-extended to 8 bits).
//   bus_out     : The resulting 8-bit shared system bus value.
// =====================================================================
module bus_mux (
    input  wire        CO,
    input  wire        RO,
    input  wire        AO,
    input  wire        EO,
    input  wire        IO,
    input  wire [3:0]  pc_val,
    input  wire [7:0]  ram_val,
    input  wire [7:0]  a_val,
    input  wire [7:0]  alu_val,
    input  wire [3:0]  ir_operand,
    output reg  [7:0]  bus_out
);

    always @(*) begin
        bus_out = 8'h00;
        if (CO)
            bus_out = {4'b0000, pc_val};
        else if (RO)
            bus_out = ram_val;
        else if (AO)
            bus_out = a_val;
        else if (EO)
            bus_out = alu_val;
        else if (IO)
            bus_out = {4'b0000, ir_operand};
    end

endmodule
