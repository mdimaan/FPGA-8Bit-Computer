// =====================================================================
// Testbench   : bus_mux_tb
// Unit Under Test : bus_mux.v (purely combinational)
// -----------------------------------------------------------------------
// Stimulus:
//   1. All select lines low -> bus_out = 0x00 (default).
//   2. CO=1 -> bus_out = zero-extended pc_val.
//   3. RO=1 -> bus_out = ram_val.
//   4. AO=1 -> bus_out = a_val.
//   5. EO=1 -> bus_out = alu_val.
//   6. IO=1 -> bus_out = zero-extended ir_operand.
//   7. Priority check: CO=1 and RO=1 together -> CO wins (CO is
//      checked first in the if/else-if chain). In real operation the
//      controller never asserts two source-enables simultaneously,
//      but the mux's defined priority is verified here for safety.
//
// Expected Waveform (bus_mux_tb.vcd):
//   bus_out jumps immediately (combinationally) to the selected
//   source's value each time the corresponding *_val input or select
//   line changes -- no clock is involved.
// =====================================================================
`timescale 1ns/1ps

module bus_mux_tb;

    reg CO, RO, AO, EO, IO;
    reg [3:0] pc_val;
    reg [7:0] ram_val, a_val, alu_val;
    reg [3:0] ir_operand;
    wire [7:0] bus_out;
    integer errors = 0;

    bus_mux UUT (
        .CO(CO), .RO(RO), .AO(AO), .EO(EO), .IO(IO),
        .pc_val(pc_val), .ram_val(ram_val), .a_val(a_val),
        .alu_val(alu_val), .ir_operand(ir_operand), .bus_out(bus_out)
    );

    task check(input [7:0] expected, input [255:0] msg);
        begin
            #1;
            if (bus_out !== expected) begin
                $display("FAIL: %0s | expected=%h actual=%h", msg, expected, bus_out);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | bus_out=%h", msg, bus_out);
            end
        end
    endtask

    initial begin
        $dumpfile("bus_mux_tb.vcd");
        $dumpvars(0, bus_mux_tb);

        CO=0; RO=0; AO=0; EO=0; IO=0;
        pc_val = 4'hA; ram_val = 8'h11; a_val = 8'h22; alu_val = 8'h33; ir_operand = 4'h5;

        check(8'h00, "all selects low -> bus=0x00");

        CO = 1; check(8'h0A, "CO=1 -> bus=pc_val (zero-extended 0x0A)");
        CO = 0; RO = 1; check(8'h11, "RO=1 -> bus=ram_val");
        RO = 0; AO = 1; check(8'h22, "AO=1 -> bus=a_val");
        AO = 0; EO = 1; check(8'h33, "EO=1 -> bus=alu_val");
        EO = 0; IO = 1; check(8'h05, "IO=1 -> bus=ir_operand (zero-extended 0x05)");

        IO = 0; CO = 1; RO = 1;
        check(8'h0A, "CO and RO both asserted -> CO has priority");

        if (errors == 0)
            $display("BUS_MUX_TB: ALL TESTS PASSED");
        else
            $display("BUS_MUX_TB: %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
