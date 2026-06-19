## =====================================================================
## File        : sap_top.xdc
## Target      : RealDigital Boolean Board (Xilinx Spartan-7 xc7s50csga324-1)
## Purpose     : Physical pin constraints for sap_top.v
## -----------------------------------------------------------------------
## Pin locations below (clock, all 16 DIP switches, and seven-segment
## display group 0) are taken directly from the Boolean Board's own
## Vivado board-file pin definitions (part0_pins.xml), so the
## clk_100mhz / GPIO_DIP_SW* / GPIO_7SEG_0_* names and LOC values are
## verified-correct for this exact board.
##
## ONE THING THAT IS NOT independently verified here: the mapping from
## the board's SEG_0..SEG_6 pin *names* to the physical segments
## a..g. This file assumes the common Digilent/RealDigital convention
## SEG_0=a, SEG_1=b, SEG_2=c, SEG_3=d, SEG_4=e, SEG_5=f, SEG_6=g,
## SEG_7=dp (matched exactly to the bit order produced by seven_seg.v,
## where seg[0]=a ... seg[6]=g). If the digits appear as a scrambled
## but stable pattern on real hardware, swap the SEG_x assignments
## below to match your board's schematic -- no other change is needed.
## =====================================================================

## ---------------------------------------------------------------------
## Mandatory Spartan-7 bitstream configuration (required by Vivado DRC)
## ---------------------------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## ---------------------------------------------------------------------
## System clock : 100 MHz onboard oscillator
## ---------------------------------------------------------------------
set_property -dict { PACKAGE_PIN F14  IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports { CLK100MHZ }];

## ---------------------------------------------------------------------
## Slide switches SW[15:0]
##   SW[3:0]  = RAM Address      (Program Mode)
##   SW[11:4] = RAM Data         (Program Mode)
##   SW[12]   = WRITE            (one-shot commit pulse)
##   SW[13]   = RUN              (1 = Run Mode, 0 = Program Mode)
##   SW[14]   = RESET
##   SW[15]   = STEP             (one-shot manual clock pulse)
## ---------------------------------------------------------------------
set_property -dict { PACKAGE_PIN V2 IOSTANDARD LVCMOS33 } [get_ports { SW[0]  }];
set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports { SW[1]  }];
set_property -dict { PACKAGE_PIN U1 IOSTANDARD LVCMOS33 } [get_ports { SW[2]  }];
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports { SW[3]  }];
set_property -dict { PACKAGE_PIN T1 IOSTANDARD LVCMOS33 } [get_ports { SW[4]  }];
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports { SW[5]  }];
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports { SW[6]  }];
set_property -dict { PACKAGE_PIN P2 IOSTANDARD LVCMOS33 } [get_ports { SW[7]  }];
set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports { SW[8]  }];
set_property -dict { PACKAGE_PIN N2 IOSTANDARD LVCMOS33 } [get_ports { SW[9]  }];
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports { SW[10] }];
set_property -dict { PACKAGE_PIN M2 IOSTANDARD LVCMOS33 } [get_ports { SW[11] }];
set_property -dict { PACKAGE_PIN M1 IOSTANDARD LVCMOS33 } [get_ports { SW[12] }];
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { SW[13] }];
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { SW[14] }];
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { SW[15] }];

## ---------------------------------------------------------------------
## Seven-segment display (using display group 0 of 2 -- 4 digits
## available, only AN[2:0] / 3 digits are driven by seven_seg.v since
## that covers the full 0-255 range; AN[3] is always held inactive by
## the RTL but still constrained here since the AN port is 4 bits wide)
## ---------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN A8 IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];

set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]; ## segment a
set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]; ## segment b
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]; ## segment c
set_property -dict { PACKAGE_PIN B7 IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]; ## segment d
set_property -dict { PACKAGE_PIN A7 IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]; ## segment e
set_property -dict { PACKAGE_PIN D6 IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]; ## segment f
set_property -dict { PACKAGE_PIN B5 IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]; ## segment g
## NOTE: pin A6 (GPIO_7SEG_0_SEG_7 / decimal point) is intentionally
## left unconstrained -- sap_top.v does not drive a dp signal. If you
## want the decimal point permanently off, add a top-level output tied
## high and constrain it to A6, or simply leave it disconnected.

## ---------------------------------------------------------------------
## OPTIONAL: physical push-buttons as an alternative to toggling
## SW[12] (WRITE) / SW[15] (STEP) with your fingers. Both behave
## identically from the RTL's point of view (each is just a one-shot
## edge-detected pulse) -- uncomment and rewire in sap_top.v if you
## prefer momentary push-buttons over slide switches for these two
## control lines.
## ---------------------------------------------------------------------
# set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { BTN_WRITE }];
# set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports { BTN_STEP   }];
# set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports { BTN_RESET  }];
# set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports { BTN_RUN    }];
