module bus_mux (
    input  wire        CO,
    input  wire        RO,
    input  wire        AO,
    input  wire        EO,
    input  wire        IO,
    input  wire [3:0]  pc_val,
    input  wire [7:0]  ram_val,
    input  wire [7:0]  a_val,
    input  wire [7:0]  alu_val,
    input  wire [3:0]  ir_operand,
    output reg  [7:0]  bus_out
);

    always @(*) begin
        bus_out = 8'h00;
        if (CO)
            bus_out = {4'b0000, pc_val};
        else if (RO)
            bus_out = ram_val;
        else if (AO)
            bus_out = a_val;
        else if (EO)
            bus_out = alu_val;
        else if (IO)
            bus_out = {4'b0000, ir_operand};
    end

endmodule
