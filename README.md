# FPGA Implementation of an 8-Bit Computer Architecture

## Project Overview

This project presents the design and implementation of a custom **8-Bit Computer Architecture** using **Verilog HDL** on an FPGA platform. The processor is built from fundamental computer architecture components including registers, memory, arithmetic logic unit (ALU), control unit, and a shared system bus.

The architecture demonstrates the complete instruction execution process through **Fetch**, **Decode**, and **Execute** cycles. It supports arithmetic operations, logical operations, memory access, data transfer, and output display functionality while providing a clear understanding of processor internals.

The design follows synchronous digital design principles and has been verified through simulation and FPGA implementation.

---

## Table of Contents

* Problem Statement
* Features
* Tools and Hardware
* Architecture Overview
* Block Diagram
* System Components
* Instruction Format
* Instruction Set Architecture (ISA)
* Fetch Cycle
* Execute Cycle
* ALU Operations
* Control Signals
* Verilog Implementation
* FPGA Implementation
* Testing and Verification
* File Structure
* Contributors
* Conclusion

---

# Problem Statement

Modern processors contain millions of transistors and complex control logic, making it difficult for students and beginners to understand the fundamental concepts of computer architecture. There is a need for a simplified processor design that demonstrates instruction execution, memory access, arithmetic operations, and control signal generation in a clear and educational manner.

This project addresses the problem by implementing a complete **8-Bit Computer Architecture on FPGA using Verilog HDL**. The processor integrates memory, registers, control logic, and an arithmetic logic unit to execute instructions through a bus-based architecture.

The design ensures reliable operation through synchronized control signals, register-based data transfer, memory interfacing, and flag generation while maintaining a simple and understandable architecture suitable for educational and research purposes.

---

# Features

* Custom 8-Bit Processor Design
* FPGA-Based Implementation
* Shared 8-Bit System Bus
* Program Counter (PC)
* Memory Address Register (MAR)
* 32 × 8 RAM Memory
* Instruction Register (IR)
* Arithmetic Logic Unit (ALU)
* A Register (Accumulator)
* B Register
* Flag Register
* Input Register
* Output Register
* Seven Segment Display Interface
* Fetch-Decode-Execute Operation
* Control Signal Generation
* Verilog HDL Implementation
* Fully Synthesizable Design
* FPGA Hardware Verification

---

# Tools and Hardware

### FPGA Board

* AMD Xilinx FPGA Development Board

### HDL Language

* Verilog HDL

### Design Tool

* AMD Vivado 2025

### Verification

* Vivado Simulator
* FPGA Hardware Testing

---

# Architecture Overview

The processor follows a bus-based architecture where all major components communicate through a centralized **8-Bit System Bus**.

The architecture consists of:

* Program Counter (PC)
* Memory Address Register (MAR)
* RAM
* Instruction Register (IR)
* Control Unit
* ALU
* A Register
* B Register
* Flag Register
* Input Register
* Output Register
* Output Display

The Control Unit coordinates all operations using dedicated control signals and timing states.

---

# Block Diagram

<img width="3360" height="4762" alt="8bit_computer_architecture_v3" src="https://github.com/user-attachments/assets/5755350d-5b48-4708-affd-69e477e4cc8a" />


# System Components

## Program Counter (PC)

Stores the address of the next instruction to be executed.

### Functions

* Holds current instruction address
* Increments after fetch cycle
* Places address on system bus

---

## Memory Address Register (MAR)

Stores memory addresses for RAM access.

### Functions

* Receives address from PC
* Selects RAM location
* Supports memory read and write operations

---

## RAM (32 × 8)

Stores program instructions and data.

### Functions

* Read operation
* Write operation
* Instruction storage
* Data storage

---

## Instruction Register (IR)

Stores fetched instruction.

### Functions

* Holds Opcode
* Holds Operand
* Sends instruction information to Control Unit

---

## Arithmetic Logic Unit (ALU)

Performs arithmetic and logical operations.

### Supported Operations

* ADD
* SUB
* DIV
* AND
* OR
* XOR
* NOT

---

## A Register

Primary accumulator register.

### Functions

* Stores ALU results
* Provides first ALU operand

---

## B Register

Secondary register.

### Functions

* Provides second ALU operand
* Stores temporary data

---

## Flag Register

Stores processor status flags.

### Flags

* Zero Flag (ZF)
* Carry Flag (CF)

---

## Input Register

Receives external input data.

### Functions

* Data acquisition
* User input interface

---

## Output Register

Stores processed output data.

### Functions

* Receives data from bus
* Sends data to display

---

# Instruction Format

The processor uses an 8-bit instruction format.

| Field   | Size   |
| ------- | ------ |
| Opcode  | 4 Bits |
| Operand | 4 Bits |

### Format

```text
--------------------------------
| Opcode (4) | Operand (4) |
--------------------------------
```

---

# Instruction Set Architecture (ISA)

| Opcode | Mnemonic | Description          |
| ------ | -------- | -------------------- |
| 0000   | LDA      | Load Accumulator     |
| 0001   | ADD      | Add Memory Data      |
| 0010   | SUB      | Subtract Memory Data |
| 1000   | OUT      | Output Data          |
| 1111   | HLT      | Halt Processor       |

---

# Fetch Cycle

### T0

```text
PC → BUS → MAR
```

### T1

```text
RAM → BUS → IR
```

### T2

```text
PC = PC + 1
```

---

# Execute Cycle

### T3 – T5

Depending on the opcode:

* Load data
* Perform ALU operation
* Store result
* Generate flags
* Send output

---

# ALU Operations

The ALU supports:

### Arithmetic

* Addition
* Subtraction
* Division

### Logical

* AND
* OR
* XOR
* NOT

The ALU updates the Flag Register after each operation.

---

# Control Signals

| Signal | Description        |
| ------ | ------------------ |
| CO     | Counter Out        |
| CE     | Counter Enable     |
| CL     | Counter Load       |
| MI     | MAR In             |
| RI     | RAM In             |
| RO     | RAM Out            |
| II     | Instruction In     |
| IO     | Instruction Out    |
| AI     | A Register In      |
| AO     | A Register Out     |
| BI     | B Register In      |
| EO     | ALU Out            |
| FI     | Flag Register In   |
| OI     | Output Register In |
| HLT    | Halt               |

---

# Verilog Implementation

### Main Modules

```text
top.v
control_unit.v
program_counter.v
mar.v
ram.v
instruction_register.v
alu.v
a_register.v
b_register.v
flag_register.v
input_register.v
output_register.v
```

---

# FPGA Implementation

The architecture was synthesized and implemented using AMD Vivado.

### FPGA Resources

* LUTs
* Flip-Flops
* Block RAM
* Clock Resources

The design successfully executed instructions and displayed output on FPGA hardware.

---

# Testing and Verification

The processor was verified through:

* Functional Simulation
* RTL Verification
* Timing Verification
* FPGA Hardware Testing

### Verified Operations

* Memory Read
* Memory Write
* Instruction Fetch
* Instruction Decode
* ALU Operations
* Flag Generation
* Output Display

---

# File Structure

```text
FPGA_8BIT_COMPUTER/
│
├── rtl/
│   ├── alu.v
│   ├── program_counter.v
│   ├── mar.v
│   ├── ram.v
│   ├── instruction_register.v
│   ├── control_unit.v
│   ├── a_register.v
│   ├── b_register.v
│   ├── flag_register.v
│   ├── input_register.v
│   ├── output_register.v
│   └── top.v
│
├── sim/
├── constraints/
├── images/
├── docs/
└── README.md
```

---

# Contributors

### Velmurugan R

B.E. Electrical and Electronics Engineering
Bannari Amman Institute of Technology

GitHub: https://github.com/velmurugan-vlsi

 ### Harish P

B.E. Electrical and Electronics Engineering
Bannari Amman Institute of Technology

GitHub: https://github.com/harishee129

### Mohammed Shakil Imaan A

B.E. Electrical and Electronics Engineering
Bannari Amman Institute of Technology

### Faculty Mentor

Dr. Elango Sekar
Associate Professor, Department of ECE
Bannari Amman Institute of Technology

**BIT – Centre for SoC and FPGA Design**

---

# Conclusion

This project successfully demonstrates the design and FPGA implementation of a custom **8-Bit Computer Architecture** using Verilog HDL. The architecture provides a practical understanding of processor design concepts including memory interfacing, instruction execution, ALU operations, register transfers, control logic, and bus-based communication.

The project serves as an excellent educational platform for learning computer organization, digital design, FPGA development, and processor architecture fundamentals.

---

# Notes

This project enhanced understanding of:

* Computer Architecture
* Processor Design
* Register Transfer Logic (RTL)
* Verilog HDL
* FPGA Design Flow
* Control Unit Design
* ALU Design
* Memory Interfacing
* Timing and Synchronization
* Digital System Verification
