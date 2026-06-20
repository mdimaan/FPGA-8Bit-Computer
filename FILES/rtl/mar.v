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
