module ram (
    input  wire        clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        clear_all,
    input  wire         run_mode,
    input  wire [3:0]   addr_run,
    input  wire         RI,
    input  wire [7:0]   bus_in,
    input  wire [3:0]   prog_addr,
    input  wire [7:0]   prog_data,
    input  wire         prog_write,
    output wire [7:0]   ram_out
);

    reg [7:0] mem [0:15];
    integer i;
    integer clr_idx;

    wire [3:0] addr_sel = run_mode ? addr_run : prog_addr;
    assign ram_out = mem[addr_sel];

    always @(posedge clk) begin
        if (clear_all) begin
            for (clr_idx = 0; clr_idx < 16; clr_idx = clr_idx + 1)
                mem[clr_idx] <= 8'h00;
        end
        else if (run_mode) begin
            if (!reset && EN && RI)
                mem[addr_run] <= bus_in;
        end
        else begin
            if (prog_write)
                mem[prog_addr] <= prog_data;
        end
    end
    initial begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 8'h00;
    end

endmodule
