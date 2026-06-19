// =====================================================================
// Module      : step_counter
// Purpose     : Generates the five timing states T1..T5 that drive
//               controller.v. One-hot encoded. Cycles T1->T2->T3->
//               T4->T5->T1 continuously, except when frozen by hlt.
// -----------------------------------------------------------------------
// Signal Explanation:
//   clk      : System clock.
//   reset    : Synchronous, active-high. Forces step back to T1.
//   EN       : Global CPU clock-enable ("tick"). The step register
//              only advances on a clock edge where EN=1, which is
//              what makes manual single-stepping (via the STEP
//              switch in sap_top.v) possible.
//   hlt      : Halt indication from controller.v (combinationally
//              true while step=T3 and the latched opcode is HLT).
//              While hlt=1, the counter is frozen in place -- it
//              never advances even if EN pulses -- which permanently
//              parks the CPU at T3/HLT until the next reset.
//   step     : One-hot 5-bit timing word:
//                step[0]=T1, step[1]=T2, step[2]=T3,
//                step[3]=T4, step[4]=T5
// =====================================================================
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
