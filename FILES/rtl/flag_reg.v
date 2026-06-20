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
