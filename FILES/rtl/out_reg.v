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
