module ir (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        II,
    input  wire [7:0]  bus_in,
    output reg  [7:0]  ir_out,
    output wire [3:0]  opcode,
    output wire [3:0]  operand
);

    always @(posedge clk) begin
        if (reset)
            ir_out <= 8'h00;
        else if (EN && II)
            ir_out <= bus_in;
    end

    assign opcode  = ir_out[7:4];
    assign operand = ir_out[3:0];

endmodule
