// =====================================================================
// Module      : out_reg
// Purpose     : 8-bit Output Register. Latches the value to be shown
//               on the seven-segment display when the OUT instruction
//               executes. Decouples the display from the accumulator
//               so A can keep changing after a value has been "output".
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock.
//   reset    : Synchronous, active-high. Clears output to 0x00.
//   EN       : Global CPU clock-enable ("tick").
//   OI       : Output-register-In control signal. When OI=1 (and
//              EN=1), out_val <= bus_in.
//   bus_in   : 8-bit shared system bus.
//   out_val  : Latched value, 0-255, driven into seven_seg.v.
// =====================================================================
module out_reg (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        OI,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  out_val
);

    always @(posedge clk) begin
        if (reset)
            out_val <= 8'h00;
        else if (EN && OI)
            out_val <= bus_in;
    end

endmodule
