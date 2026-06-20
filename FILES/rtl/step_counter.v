module step_counter (
    input  wire       clk,
    input  wire        reset,
    input  wire        EN,
    input  wire        hlt,
    output reg  [4:0]  step
);

    localparam T1 = 5'b00001;
    localparam T2 = 5'b00010;
    localparam T3 = 5'b00100;
    localparam T4 = 5'b01000;
    localparam T5 = 5'b10000;

    always @(posedge clk) begin
        if (reset)
            step <= T1;
        else if (EN && !hlt) begin
            case (step)
                T1:      step <= T2;
                T2:      step <= T3;
                T3:      step <= T4;
                T4:      step <= T5;
                T5:      step <= T1;
                default: step <= T1;
            endcase
        end
    end

endmodule
