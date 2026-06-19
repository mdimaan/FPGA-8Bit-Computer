// =====================================================================
// Module      : controller
// Purpose     : Hardwired control unit. Combinationally decodes the
//               current timing state (step, from step_counter.v) and
//               the latched opcode (from ir.v) into the set of
//               micro-operation control signals that drive every
//               other module. This is the "ROM-less" SAP-1 style
//               control approach: step_counter.v is the only state
//               register, and controller.v is a pure decoder.
// -----------------------------------------------------------------------
// Signal Explanation (outputs):
//   CO   : PC output enable           (PC -> bus)
//   CE   : PC count enable             (PC <= PC+1)
//   MI   : MAR load enable             (bus -> MAR)
//   RO   : RAM output enable           (RAM -> bus)
//   RI   : RAM write enable            (bus -> RAM)
//   II   : IR load enable              (bus -> IR)
//   IO   : IR operand output enable    (IR[3:0] -> bus)
//   AI   : A register load enable      (bus -> A)
//   AO   : A register output enable    (A -> bus)
//   BI   : B register load enable      (bus -> B)
//   OI   : Output register load enable (bus -> OUT)
//   LP   : PC load enable (jump)       (bus[3:0] -> PC)
//   SU   : ALU subtract select         (0=ADD, 1=SUB)
//   EO   : ALU output enable           (ALU result -> bus)
//   FI   : Flag register load enable   (ALU flags -> FLAGS)
//   HLT  : Halt indication. Freezes step_counter.v when 1.
//
// Inputs:
//   step      : One-hot timing state from step_counter.v (T1..T5).
//   opcode    : 4-bit latched opcode from ir.v.
//   zero_flag : Registered Zero Flag from flag_reg.v, tested by JZ.
// =====================================================================
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
        // Safe default: every control signal low unless explicitly
        // asserted below for the current (step, opcode) combination.
        CO = 1'b0; CE = 1'b0; MI = 1'b0; RO = 1'b0; RI = 1'b0;
        II = 1'b0; IO = 1'b0; AI = 1'b0; AO = 1'b0; BI = 1'b0;
        OI = 1'b0; LP = 1'b0; SU = 1'b0; EO = 1'b0; FI = 1'b0;
        HLT = 1'b0;

        case (step)

            // ---------------- FETCH (common to every instruction) ----
            T1: begin
                CO = 1'b1;   // PC -> bus
                MI = 1'b1;   // bus -> MAR
            end

            T2: begin
                RO = 1'b1;   // RAM -> bus
                II = 1'b1;   // bus -> IR
                CE = 1'b1;   // PC <= PC + 1
            end

            // ---------------- EXECUTE ---------------------------------
            T3: begin
                case (opcode)
                    OP_LDA, OP_ADD, OP_SUB, OP_STA: begin
                        IO = 1'b1;   // IR operand -> bus
                        MI = 1'b1;   // bus -> MAR
                    end
                    OP_JMP: begin
                        IO = 1'b1;   // IR operand -> bus
                        LP = 1'b1;   // bus -> PC
                    end
                    OP_JZ: begin
                        if (zero_flag) begin
                            IO = 1'b1;
                            LP = 1'b1;
                        end
                        // zero_flag == 0 : no operation this step;
                        // T4/T5 are also NOPs for JZ (see below), so
                        // the instruction simply falls through to the
                        // next fetch after 5 T-states either way.
                    end
                    OP_OUT: begin
                        AO = 1'b1;   // A -> bus
                        OI = 1'b1;   // bus -> OUT
                    end
                    OP_HLT: begin
                        HLT = 1'b1;  // freeze step_counter
                    end
                    default: ; // undefined opcode -> NOP
                endcase
            end

            T4: begin
                case (opcode)
                    OP_LDA: begin RO = 1'b1; AI = 1'b1; end // RAM->bus->A
                    OP_ADD: begin RO = 1'b1; BI = 1'b1; end // RAM->bus->B
                    OP_SUB: begin RO = 1'b1; BI = 1'b1; end // RAM->bus->B
                    OP_STA: begin AO = 1'b1; RI = 1'b1; end // A->bus->RAM
                    default: ; // LDA/JMP/JZ/OUT/HLT already done by T3
                endcase
            end

            T5: begin
                case (opcode)
                    OP_ADD: begin EO = 1'b1; AI = 1'b1; FI = 1'b1; SU = 1'b0; end
                    OP_SUB: begin EO = 1'b1; AI = 1'b1; FI = 1'b1; SU = 1'b1; end
                    default: ; // only ADD/SUB use T5
                endcase
            end

            default: ; // unreachable (one-hot step)
        endcase
    end

endmodule
