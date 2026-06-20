module alu (
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire        SU,
    output wire [7:0] result,
    output wire        zero_flag,
    output wire        carry_flag
);

    wire [8:0] add_res = {1'b0, a_in} + {1'b0, b_in};
    wire [8:0] sub_res = {1'b0, a_in} + {1'b0, ~b_in} + 9'b1;

    assign {carry_flag, result} = SU ? sub_res : add_res;
    assign zero_flag = (result == 8'h00);

endmodule
