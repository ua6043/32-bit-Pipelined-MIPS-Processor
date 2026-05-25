# 32-bit Pipelined MIPS Processor in VHDL

A 32-bit FPGA-based MIPS processor core designed in VHDL and implemented on a Digilent Basys 3 FPGA. The processor uses a registered five-stage pipeline: Instruction Fetch, Instruction Decode, Execute, Memory, and Writeback. Pipeline registers connect the stages and allow instructions to move through the datapath cycle by cycle.

## Features

- 32-bit MIPS-style datapath
- Five-stage registered pipeline:
  - Instruction Fetch
  - Instruction Decode
  - Execute
  - Memory
  - Writeback
- VHDL RTL implementation for each processor stage
- Register file with two asynchronous read ports and one synchronous write port
- Structural ALU with arithmetic, logic, shift, and multiplication support
- Byte-addressed instruction memory initialized with machine-code programs
- Data memory with memory-mapped switch input and seven-segment display output
- Basys 3 FPGA hardware demonstration
- Vivado simulation, synthesis, implementation, and timing analysis

## Architecture

The top-level `Microprocessor` module instantiates the five pipeline stages and connects them using clocked pipeline registers. The design includes an extra memory delay stage to align synchronous memory read data with writeback control signals.

Main modules:

- `InstructionFetch`: program counter and instruction memory access
- `InstructionDecode`: instruction parsing, control generation, register file access, and immediate extension
- `ExecuteStage`: ALU operand selection, ALU execution, destination register selection
- `MemoryStage`: data memory access and seven-segment output control
- `WritebackStage`: selects ALU result or memory data for register writeback

## Supported Instructions

### R-Type
- ADD
- SUB
- AND
- OR
- XOR
- MULTU
- SLL
- SRL
- SRA

### I-Type
- ADDI
- ANDI
- ORI
- XORI
- LW
- SW

Branch and jump instructions are not implemented in this version.

## Memory-Mapped I/O

The data memory includes two memory-mapped hardware addresses for FPGA testing:

| Address | Function |
|---|---|
| 1022 | Reads the 16 Basys 3 switches |
| 1023 | Writes the lower 16 bits to the seven-segment display path |

This allowed machine-code programs to read external switch input, process the value through the pipeline, and display the result on the Basys 3 seven-segment display.

The processor was verified in stages and then as an integrated pipeline.

- Individual stage testbenches were used for Instruction Fetch, Instruction Decode, Execute, Memory, and Writeback.
- The integrated processor was tested by loading machine-code programs into instruction memory.
- Simulation waveforms were used to trace instruction flow through Fetch, Decode, Execute, Memory, and Writeback.
- Test programs verified arithmetic, logic, load/store, memory-mapped I/O, and Fibonacci sequence generation.
- The design was synthesized, implemented, and tested on a Basys 3 FPGA.

## FPGA Demo

The hardware demo used switch input and seven-segment display output through memory-mapped I/O. A MIPS machine-code program read switch values, performed ALU operations, and wrote results to the seven-segment display.

## Timing Analysis

Post-implementation timing analysis was performed in Vivado by varying the processor clock frequency and checking setup and hold timing results after implementation.

The processor operated successfully from **10 MHz to 44 MHz**. At **45 MHz**, the design failed timing because the **setup time became negative**. Hold timing remained positive across all tested frequencies.

**Highest verified operating frequency: 44 MHz**

| Clock Frequency (MHz) | Setup Time (ns) | Hold Time (ns) | Status |
|----------------------:|----------------:|---------------:|--------|
| 10  | 44.483 | 0.023 | Succeeded |
| 15  | 28.148 | 0.009 | Succeeded |
| 20  | 20.457 | 0.035 | Succeeded |
| 25  | 13.675 | 0.034 | Succeeded |
| 30  | 7.422  | 0.028 | Succeeded |
| 35  | 3.572  | 0.019 | Succeeded |
| 40  | 1.374  | 0.039 | Succeeded |
| 41  | 1.689  | 0.037 | Succeeded |
| 42  | 0.248  | 0.019 | Succeeded |
| 43  | 0.360  | 0.022 | Succeeded |
| 44  | 0.083  | 0.022 | Succeeded |
| 45  | -0.042 | 0.030 | Failed |
