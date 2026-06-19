// =====================================================================
// Module      : seven_seg
// Purpose     : Converts an 8-bit binary value (0-255) into a 3-digit
//               decimal representation and time-multiplexes it across
//               the board's seven-segment digits.
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock (CLK100MHZ). Drives the digit-refresh
//              counter; no separate slow clock is required.
//   reset    : Synchronous, active-high. Restarts the refresh counter.
//   value    : 8-bit binary value to display (0-255).
//   seg      : 7-bit active-low segment pattern {g,f,e,d,c,b,a} for
//              the currently selected digit. NOTE: confirm this bit
//              order and polarity against the Boolean board's actual
//              XDC/datasheet pin mapping -- 7-seg wiring conventions
//              differ between boards.
//   an       : 4-bit active-low anode/digit-select. Bit0 selects the
//              ones digit, bit1 the tens digit, bit2 the hundreds
//              digit; bit3 (4th digit) is always blanked (driven
//              high / off) since only 3 digits are needed for 0-255.
// -----------------------------------------------------------------------
// Internal operation:
//   1. Combinational binary-to-BCD split using '/' and '%'. For an
//      8-bit operand this synthesizes to a small, fully acceptable
//      combinational divider in Vivado.
//   2. An 18-bit free-running counter divides CLK100MHZ down to a
//      ~380 Hz per-digit refresh rate (full 3-digit cycle ~1.3 kHz),
//      fast enough that the human eye sees a steady display with
//      no visible flicker.
//   3. A 2-bit digit_sel field (taken from the top of the refresh
//      counter) selects which BCD digit and which anode line is
//      active this refresh slot.
//   4. A standard 7-segment decoder converts the selected BCD digit
//      into the segment pattern.
// =====================================================================
module seven_seg (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  value,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);

    // ---- Binary to 3-digit BCD (combinational) -----------------------
    wire [3:0] hundreds = value / 100;
    wire [3:0] tens     = (value / 10) % 10;
    wire [3:0] ones     = value % 10;

    // ---- Digit refresh counter ----------------------------------------
    reg [17:0] refresh_cnt;
    wire [1:0] digit_sel = refresh_cnt[17:16];

    always @(posedge clk) begin
        if (reset)
            refresh_cnt <= 18'd0;
        else
            refresh_cnt <= refresh_cnt + 18'd1;
    end

    // ---- Digit / anode select -----------------------------------------
    reg [3:0] bcd_digit;

    always @(*) begin
        case (digit_sel)
            2'b00:   begin bcd_digit = ones;     an = 4'b1110; end // AN0 active
            2'b01:   begin bcd_digit = tens;     an = 4'b1101; end // AN1 active
            2'b10:   begin bcd_digit = hundreds; an = 4'b1011; end // AN2 active
            default: begin bcd_digit = 4'hF;     an = 4'b1111; end // blank
        endcase
    end

    // ---- 7-segment decoder (active-low, common-anode style) -----------
    always @(*) begin
        case (bcd_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // blank
        endcase
    end

endmodule
