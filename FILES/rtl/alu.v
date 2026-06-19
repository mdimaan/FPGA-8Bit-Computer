// =====================================================================
// Module      : alu
// Purpose     : 8-bit combinational Arithmetic Logic Unit. Performs
//               ADD or SUBTRACT on the A and B registers and produces
//               the result plus Zero/Carry status, all combinationally
//               (no clock -- it is pure logic between B and A/FLAGS).
// -----------------------------------------------------------------------
// Signal Explanation:
//   a_in        : Accumulator (A register) value.
//   b_in        : B register value.
//   SU          : Subtract-select control signal from controller.v.
//                 SU=0 -> result = a_in + b_in   (ADD)
//                 SU=1 -> result = a_in - b_in   (SUB, via 2's complement)
//   result      : 8-bit ALU output. Gated onto the bus by bus_mux.v
//                 whenever EO=1.
//   zero_flag   : 1 when result == 0, else 0 (combinational).
//   carry_flag  : Carry-out of the addition (ADD), or the equivalent
//                 carry-out of the 2's-complement subtraction (SUB).
//                 For SUB, carry_flag=1 means "no borrow occurred"
//                 (a_in >= b_in), which is the standard convention
//                 for an adder-based subtractor.
// -----------------------------------------------------------------------
// Note on EO: the project's control-signal list (CO, CE, MI, RO, RI,
// II, IO, AI, AO, BI, OI, LP, SU, HLT, FI) does not include a separate
// "ALU output enable" signal, yet the micro-op table requires the ALU
// result to be placed on the bus during T5 of ADD/SUB ("ALU AI FI").
// Signal EO (ALU Output) is added for exactly this purpose -- it is
// the direct, necessary equivalent of the "E" output-enable found in
// the classic Malvino/Ben-Eater SAP-1 control word. Without it there
// is no way to drive the bus from the ALU.
// =====================================================================
module alu (
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire        SU,
    output wire [7:0] result,
    output wire        zero_flag,
    output wire        carry_flag
);

    wire [8:0] add_res = {1'b0, a_in} + {1'b0, b_in};
    wire [8:0] sub_res = {1'b0, a_in} + {1'b0, ~b_in} + 9'b1;

    assign {carry_flag, result} = SU ? sub_res : add_res;
    assign zero_flag = (result == 8'h00);

endmodule
