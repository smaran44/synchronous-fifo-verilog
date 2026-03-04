# Synchronous FIFO in Verilog

Fully parameterized synchronous FIFO (First-In First-Out) buffer designed and verified in Verilog. The design implements circular buffer architecture with read/write pointers and includes status flags such as full, empty, almost full, almost empty, and occupancy counter. Verified using a structured Verilog testbench and simulated in Vivado.

## Features

* Parameterized FIFO depth and data width
* Circular buffer architecture using read and write pointers
* Full and empty detection using pointer comparison
* Almost full and almost empty status flags
* FIFO occupancy tracking using fill counter
* Registered read data output
* Structured testbench with multiple verification scenarios
* Waveform-verified FIFO behavior
* RTL and synthesis schematics included

## Folder Structure

rtl/ → FIFO RTL design
tb/ → Testbench for FIFO verification
sim/ → Simulation waveforms and outputs
schematics/ → RTL and synthesis schematics

## Tools Used

* Verilog HDL
* Xilinx Vivado Simulator

## Verification

The FIFO was verified using multiple simulation scenarios:

* Basic write and read operations
* FIFO full condition validation
* FIFO empty condition validation
* Almost full threshold verification
* Almost empty threshold verification

Waveforms confirm correct FIFO ordering, pointer wrapping, and flag behavior.

## Author

Smaran Yanapu
