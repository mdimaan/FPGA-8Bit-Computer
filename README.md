# FPGA-8Bit-Computer
PROJECT OVERVIEW:

This project implements a custom 8-Bit Computer Architecture in Verilog HDL and targets FPGA-based hardware platforms. The design demonstrates the fundamental concepts of processor architecture, including instruction execution, memory access, arithmetic and logical processing, register operations, and control signal generation through a centralized control unit.

The architecture consists of a Program Counter (PC), Memory Address Register (MAR), RAM, Instruction Register (IR), Arithmetic Logic Unit (ALU), A Register, B Register, Input Register, Output Register, Flag Register, and an 8-bit System Bus. Instructions are executed through a structured Fetch–Execute cycle, enabling efficient data movement and processing across the system.

The processor supports arithmetic operations, logical operations, memory read/write functionality, input/output handling, and status flag generation using Carry Flag (CF) and Zero Flag (ZF) mechanisms. A four-digit seven-segment display interface provides real-time visualization of processor outputs, making the architecture suitable for educational learning, FPGA prototyping, and embedded system development.

The modular design methodology allows easy scalability for future enhancements such as advanced instruction sets, communication peripherals, sensor interfaces, AI-assisted decision engines, and intelligent embedded computing applications.

PROBLEM STATEMENT

In modern digital systems, understanding the internal operation of a processor is essential for learning computer organization, digital design, and FPGA-based system development. However, commercial processors are highly complex, making it difficult for students and beginners to visualize instruction execution, data movement, and control signal generation. This project addresses the problem by designing and implementing a custom 8-Bit Computer Architecture on FPGA using Verilog HDL.

The architecture integrates essential processor components such as the Program Counter (PC), Memory Address Register (MAR), RAM, Instruction Register (IR), Control Unit, Arithmetic Logic Unit (ALU), A Register, B Register, Flag Register, Input Register, Output Register, and System Bus. The processor executes instructions through dedicated Fetch and Execute cycles, enabling data transfer, arithmetic operations, logical operations, memory access, and output display functions.

The design ensures correct operation through synchronized control signals, bus-based data communication, register management, and flag generation. Reliable instruction execution is maintained during memory access, arithmetic computation, program sequencing, and data transfer operations, providing a complete educational microprocessor implementation suitable for FPGA platforms.
