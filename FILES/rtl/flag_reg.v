// =====================================================================
// Module      : flag_reg
// Purpose     : 2-bit Flag Register. Latches the Zero and Carry flags
//               produced combinationally by alu.v, so that JZ can test
//               the flag from a *previous* ALU operation rather than a
//               value that is still changing combinationally.
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk       : System clock.
//   reset     : Synchronous, active-high. Clears flags to 00.
//   EN        : Global CPU clock-enable ("tick").
//   FI        : Flag-In control signal, asserted by the controller in
//               the same micro-step that ALU output is gated into A
//               (T5 of ADD/SUB). When FI=1 (and EN=1), flags are
//               captured.
//   zero_in   : Combinational zero flag from alu.v.
//   carry_in  : Combinational carry flag from alu.v.
//   flags     : flags[0] = Zero Flag (ZF), flags[1] = Carry Flag (CF).
// =====================================================================
module flag_reg (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        FI,
    input  wire        zero_in,
    input  wire        carry_in,
    output reg  [1:0]  flags
);

    always @(posedge clk) begin
        if (reset)
            flags <= 2'b00;
        else if (EN && FI)
            flags <= {carry_in, zero_in};
    end

endmodule
