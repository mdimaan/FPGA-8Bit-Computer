module a_reg (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        AI,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  a_out
);

    always @(posedge clk) begin
        if (reset)
            a_out <= 8'h00;
        else if (EN && AI)
            a_out <= bus_in;
    end

endmodule
