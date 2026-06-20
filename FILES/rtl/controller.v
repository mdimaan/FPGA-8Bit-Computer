module controller (
    input  wire [4:0] step,
    input  wire [3:0] opcode,
    input  wire        zero_flag,

    output reg CO, CE, MI, RO, RI, II, IO,
    output reg AI, AO, BI, OI,
    output reg LP, SU, EO, FI,
    output reg HLT
);

    localparam T1 = 5'b00001;
    localparam T2 = 5'b00010;
    localparam T3 = 5'b00100;
    localparam T4 = 5'b01000;
    localparam T5 = 5'b10000;

    localparam OP_LDA = 4'b0000;
    localparam OP_ADD = 4'b0001;
    localparam OP_SUB = 4'b0010;
    localparam OP_STA = 4'b0011;
    localparam OP_JMP = 4'b0100;
    localparam OP_JZ  = 4'b0101;
    localparam OP_OUT = 4'b1110;
    localparam OP_HLT = 4'b1111;

    always @(*) begin
        CO = 1'b0; CE = 1'b0; MI = 1'b0; RO = 1'b0; RI = 1'b0;
        II = 1'b0; IO = 1'b0; AI = 1'b0; AO = 1'b0; BI = 1'b0;
        OI = 1'b0; LP = 1'b0; SU = 1'b0; EO = 1'b0; FI = 1'b0;
        HLT = 1'b0;

        case (step)
            T1: begin
                CO = 1'b1;   
                MI = 1'b1;   
            end
            T2: begin
                RO = 1'b1;   
                II = 1'b1;   
                CE = 1'b1;   
            end
            T3: begin
                case (opcode)
                    OP_LDA, OP_ADD, OP_SUB, OP_STA: begin
                        IO = 1'b1;   
                        MI = 1'b1;   
                    end
                    OP_JMP: begin
                        IO = 1'b1;   
                        LP = 1'b1;   
                    end
                    OP_JZ: begin
                        if (zero_flag) begin
                            IO = 1'b1;
                            LP = 1'b1;
                        end
                    end
                    OP_OUT: begin
                        AO = 1'b1;   
                        OI = 1'b1;   
                    end
                    OP_HLT: begin
                        HLT = 1'b1;  
                    end
                    default: ;
                endcase
            end
            T4: begin
                case (opcode)
                    OP_LDA: begin RO = 1'b1; AI = 1'b1; end 
                    OP_ADD: begin RO = 1'b1; BI = 1'b1; end 
                    OP_SUB: begin RO = 1'b1; BI = 1'b1; end 
                    OP_STA: begin AO = 1'b1; RI = 1'b1; end 
                    default: ; 
                endcase
            end
            T5: begin
                case (opcode)
                    OP_ADD: begin EO = 1'b1; AI = 1'b1; FI = 1'b1; SU = 1'b0; end
                    OP_SUB: begin EO = 1'b1; AI = 1'b1; FI = 1'b1; SU = 1'b1; end
                    default: ; 
                endcase
            end

            default: ; 
        endcase
    end

endmodule
