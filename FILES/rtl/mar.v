// =====================================================================
// Module      : mar
// Purpose     : 4-bit Memory Address Register. Holds the RAM address
//               that the CPU currently wants to access (for either an
//               instruction fetch or a data read/write). MAR drives
//               RAM's address port directly -- it is NOT placed back
//               onto the shared bus (matches classic SAP-1: there is
//               no "MAR output enable" signal).
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock.
//   reset    : Synchronous, active-high. Forces MAR back to 0000.
//   EN       : Global CPU clock-enable ("tick").
//   MI       : Memory-address-In control signal. When MI=1 (and EN=1),
//              MAR <= bus_in[3:0].
//   bus_in   : 8-bit shared system bus (lower nibble used).
//   mar_out  : Current 4-bit address, wired straight to ram.v's
//              addr_run port.
// =====================================================================
module mar (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        MI,
    input  wire [7:0]  bus_in,
    output reg  [3:0]  mar_out
);

    always @(posedge clk) begin
        if (reset)
            mar_out <= 4'b0000;
        else if (EN && MI)
            mar_out <= bus_in[3:0];
    end

endmodule
