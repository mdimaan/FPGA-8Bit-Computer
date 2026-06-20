module b_reg (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        BI,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  b_out
);

    always @(posedge clk) begin
        if (reset)
            b_out <= 8'h00;
        else if (EN && BI)
            b_out <= bus_in;
    end

endmodule
