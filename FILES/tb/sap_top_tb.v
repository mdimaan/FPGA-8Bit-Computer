// =====================================================================
// Testbench   : sap_top_tb
// Unit Under Test : sap_top.v (full machine)
// -----------------------------------------------------------------------
// This testbench drives the DUT exactly the way a person at the
// switches would: it sets SW[3:0]/SW[11:4], pulses SW[12] (WRITE) to
// load a program into RAM, then sets SW[13]=RUN and pulses SW[15]
// (STEP) once per required tick to walk the CPU through fetch/execute
// for every instruction, checking internal datapath signals after
// each instruction completes.
//
// Two programs are run (covering all 8 opcodes between them):
//
//   PROGRAM 1 -- exercises LDA, SUB, JZ (taken), LDA, OUT, HLT
//     addr0 : LDA 9      (0x09)
//     addr1 : SUB 10     (0x2A)
//     addr2 : JZ 6        (0x56)
//     addr3 : OUT         (0xE0)   <- never reached (JZ taken)
//     addr4 : HLT         (0xF0)   <- never reached
//     addr6 : LDA 11      (0x0B)
//     addr7 : OUT         (0xE0)
//     addr8 : HLT         (0xF0)
//     addr9 : data = 5
//     addr10: data = 5            (5-5=0 -> ZF=1 -> JZ taken)
//     addr11: data = 42 (0x2A)
//   Expected: A=0 after SUB (ZF=1), PC jumps to 6, A=42 after 2nd LDA,
//             out_val=42, HLT freezes the machine permanently.
//
//   PROGRAM 2 -- exercises LDA, ADD, STA, JMP, LDA, OUT, HLT
//     addr0 : LDA 9       (0x09)
//     addr1 : ADD 10      (0x1A)
//     addr2 : STA 11      (0x3B)
//     addr3 : JMP 6       (0x46)
//     addr6 : LDA 11      (0x0B)
//     addr7 : OUT         (0xE0)
//     addr8 : HLT         (0xF0)
//     addr9 : data = 7
//     addr10: data = 8
//     addr11: scratch (overwritten by STA, then read back by LDA)
//   Expected: A=15 after ADD, RAM[11]=15 after STA, PC jumps to 6,
//             A=15 after 2nd LDA, out_val=15, HLT freezes the machine.
//
// Expected Waveform (sap_top_tb.vcd):
//   During programming bursts, `bus` and CPU registers stay at 0
//   (CPU frozen, EN=0). Once RUN=1 and STEP pulses begin, `step`
//   visibly cycles 00001->00010->00100->01000->10000 repeatedly,
//   `pc_val` increments after every fetch (and jumps on JMP/JZ),
//   `a_val`/`out_val` update at the expected T-states, and `HLT`
//   rises permanently at the end of each program, after which `step`
//   stops changing even though STEP continues to be pulsed.
// =====================================================================
`timescale 1ns/1ps

module sap_top_tb;

    reg        CLK100MHZ;
    reg [15:0] SW;
    wire [6:0] SEG;
    wire [3:0] AN;

    integer errors = 0;

    sap_top dut (
        .CLK100MHZ (CLK100MHZ),
        .SW        (SW),
        .SEG       (SEG),
        .AN        (AN)
    );

    always #5 CLK100MHZ = ~CLK100MHZ;

    // ------------------------------------------------------------------
    // Switch-level helper tasks (model exactly what a person would do)
    // ------------------------------------------------------------------
    task prog_write_byte(input [3:0] addr, input [7:0] data);
        begin
            SW[3:0]  = addr;
            SW[11:4] = data;
            SW[12]   = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
            SW[12]   = 1'b1;
            repeat (3) @(posedge CLK100MHZ);
            SW[12]   = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
        end
    endtask

    task step_once;
        begin
            SW[15] = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
            SW[15] = 1'b1;
            repeat (3) @(posedge CLK100MHZ);
        end
    endtask

    task do_reset;
        begin
            SW[14] = 1'b1;
            repeat (3) @(posedge CLK100MHZ);
            SW[14] = 1'b0;
            repeat (3) @(posedge CLK100MHZ);
        end
    endtask

    task check8(input [7:0] actual, input [7:0] expected, input [255:0] msg);
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h time=%0t", msg, expected, actual, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | value=%h time=%0t", msg, actual, $time);
            end
        end
    endtask

    task check1(input actual, input expected, input [255:0] msg);
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s | expected=%b actual=%b time=%0t", msg, expected, actual, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | value=%b time=%0t", msg, actual, $time);
            end
        end
    endtask

    initial begin
        $dumpfile("sap_top_tb.vcd");
        $dumpvars(0, sap_top_tb);

        CLK100MHZ = 0;
        SW = 16'h0000;

        // Hold reset briefly at simulation start
        SW[14] = 1; repeat (4) @(posedge CLK100MHZ); SW[14] = 0;
        repeat (4) @(posedge CLK100MHZ);

        // =================================================================
        // PROGRAM 1 : LDA / SUB / JZ(taken) / LDA / OUT / HLT
        // =================================================================
        SW[13] = 0; // RUN=0 : Program Mode
        prog_write_byte(4'd0,  8'h09); // LDA 9
        prog_write_byte(4'd1,  8'h2A); // SUB 10
        prog_write_byte(4'd2,  8'h56); // JZ 6
        prog_write_byte(4'd3,  8'hE0); // OUT (unreached)
        prog_write_byte(4'd4,  8'hF0); // HLT (unreached)
        prog_write_byte(4'd6,  8'h0B); // LDA 11
        prog_write_byte(4'd7,  8'hE0); // OUT
        prog_write_byte(4'd8,  8'hF0); // HLT
        prog_write_byte(4'd9,  8'h05); // data 5
        prog_write_byte(4'd10, 8'h05); // data 5
        prog_write_byte(4'd11, 8'h2A); // data 42

        do_reset(); // start CPU fresh at PC=0

        SW[13] = 1; // RUN=1 : CPU executes

        // ---- LDA 9 : 5 ticks (T1..T5, T4/T5 NOP for LDA after RO,AI@T4)
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h05, "P1: after LDA 9, A=0x05");

        // ---- SUB 10 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h00, "P1: after SUB 10, A=0x00");
        check1(dut.flags[0], 1'b1, "P1: ZF=1 after 5-5");

        // ---- JZ 6 (taken) : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8({4'b0000, dut.pc_val}, 8'h06, "P1: PC=6 after JZ taken");

        // ---- LDA 11 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h2A, "P1: after 2nd LDA, A=0x2A (42)");

        // ---- OUT : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.out_val, 8'h2A, "P1: out_val=0x2A (42) after OUT");

        // ---- HLT : 3 ticks reach T3 and freeze
        step_once; step_once; step_once;
        check1(dut.HLT, 1'b1, "P1: HLT asserted, machine halted");

        // Extra ticks must have NO further effect (frozen)
        step_once; step_once; step_once;
        check8(dut.a_val, 8'h2A, "P1: A unchanged after halt (extra steps ignored)");
        check1(dut.HLT, 1'b1, "P1: HLT still asserted after extra steps");

        // =================================================================
        // PROGRAM 2 : LDA / ADD / STA / JMP / LDA / OUT / HLT
        // =================================================================
        SW[13] = 0; // back to Program Mode to load new code
        prog_write_byte(4'd0,  8'h09); // LDA 9
        prog_write_byte(4'd1,  8'h1A); // ADD 10
        prog_write_byte(4'd2,  8'h3B); // STA 11
        prog_write_byte(4'd3,  8'h46); // JMP 6
        prog_write_byte(4'd6,  8'h0B); // LDA 11
        prog_write_byte(4'd7,  8'hE0); // OUT
        prog_write_byte(4'd8,  8'hF0); // HLT
        prog_write_byte(4'd9,  8'h07); // data 7
        prog_write_byte(4'd10, 8'h08); // data 8

        do_reset(); // restart CPU (RAM contents persist -- verified separately)

        SW[13] = 1; // RUN=1

        // ---- LDA 9 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h07, "P2: after LDA 9, A=0x07");

        // ---- ADD 10 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h0F, "P2: after ADD 10, A=0x0F (15)");
        check1(dut.flags[0], 1'b0, "P2: ZF=0 (15 != 0)");

        // ---- STA 11 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.RAM0.mem[11], 8'h0F, "P2: RAM[11]=0x0F after STA (via debug read)");

        // ---- JMP 6 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8({4'b0000, dut.pc_val}, 8'h06, "P2: PC=6 after JMP");

        // ---- LDA 11 : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.a_val, 8'h0F, "P2: after 2nd LDA, A=0x0F (15, read back from RAM)");

        // ---- OUT : 5 ticks
        step_once; step_once; step_once; step_once; step_once;
        check8(dut.out_val, 8'h0F, "P2: out_val=0x0F (15) after OUT");

        // ---- HLT : 3 ticks
        step_once; step_once; step_once;
        check1(dut.HLT, 1'b1, "P2: HLT asserted, machine halted");

        if (errors == 0)
            $display("SAP_TOP_TB: ALL TESTS PASSED");
        else
            $display("SAP_TOP_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
