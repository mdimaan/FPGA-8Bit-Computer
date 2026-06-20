module seven_seg (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  value,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);

    wire [3:0] hundreds = value / 100;
    wire [3:0] tens     = (value / 10) % 10;
    wire [3:0] ones     = value % 10;
    reg [17:0] refresh_cnt;
    wire [1:0] digit_sel = refresh_cnt[17:16];

    always @(posedge clk) begin
        if (reset)
            refresh_cnt <= 18'd0;
        else
            refresh_cnt <= refresh_cnt + 18'd1;
    end

    reg [3:0] bcd_digit;

    always @(*) begin
        case (digit_sel)
            2'b00:   begin bcd_digit = ones;     an = 4'b1110; end 
            2'b01:   begin bcd_digit = tens;     an = 4'b1101; end 
            2'b10:   begin bcd_digit = hundreds; an = 4'b1011; end 
            default: begin bcd_digit = 4'hF;     an = 4'b1111; end 
        endcase
    end

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
            default: seg = 7'b1111111; 
        endcase
    end

endmodule
