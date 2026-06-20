module pc (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        CE,
    input  wire        LP,
    input  wire [7:0]  bus_in,
    output reg  [3:0]  pc_out
);

    always @(posedge clk) begin
        if (reset)
            pc_out <= 4'b0000;
        else if (EN) begin
            if (LP)
                pc_out <= bus_in[3:0];
            else if (CE)
                pc_out <= pc_out + 4'b0001;
        end
    end

endmodule
