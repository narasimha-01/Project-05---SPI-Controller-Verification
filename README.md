# Project 05 - SPI Controller Verification using Verilog

## Overview

This project implements and verifies an **SPI (Serial Peripheral Interface) Controller** using Verilog HDL. The design simulates communication between an SPI Master and SPI Slave and verifies successful full-duplex data transfer through multiple test scenarios.

The project was developed and simulated using **Xilinx Vivado 2020.1**.

---

## Objectives

- Design SPI Master and Slave communication
- Verify full-duplex serial data transfer
- Simulate multiple communication scenarios
- Validate transmitted and received data
- Analyze simulation waveforms

---

## Tools Used

- Verilog HDL
- Xilinx Vivado 2020.1
- XSim Simulator

---

## Project Structure

```
Project-05-SPI-Controller-Verification
│
├── spi_master.v
├── spi_slave.v
├── spi_tb.v
├── README.md
```

---

## Features

- SPI Master Implementation
- SPI Slave Implementation
- Full-Duplex Communication
- Serial Clock (SCLK)
- MOSI & MISO Data Transfer
- Chip Select (CS)
- Self-checking Testbench
- Behavioral Simulation
- Waveform Analysis

---

## Verification Flow

1. Design SPI Master
2. Design SPI Slave
3. Create Testbench
4. Generate Test Vectors
5. Run Behavioral Simulation
6. Verify Data Transfer
7. Analyze Waveforms
8. Validate Test Results

---

## Test Cases

| Test Case | Description | Status |
|------------|-------------|--------|
| Test 1 | Normal Data Transfer | ✅ Pass |
| Test 2 | Boundary Values (0x00 ↔ 0xFF) | ✅ Pass |
| Test 3 | Inverse Data (0xA5 ↔ 0x5A) | ✅ Pass |
| Test 4 | Single Bit Patterns | ✅ Pass |
| Test 5 | Mixed Data Bytes | ✅ Pass |

---

## Simulation Results

The simulation successfully verified SPI communication for all test cases.

### Console Output

```
PASS | Master got expected data
PASS | Slave got expected data

All 5 tests complete
```

---

## Waveform Verification

The waveform confirms:

- Correct Chip Select (CS) operation
- Proper SPI Clock (SCLK) generation
- Successful MOSI transmission
- Successful MISO reception
- Accurate byte exchange between Master and Slave

---

## Learning Outcomes

This project helped me understand:

- SPI Communication Protocol
- Master-Slave Architecture
- Full-Duplex Data Transfer
- Verilog RTL Design
- Testbench Development
- Behavioral Simulation
- Waveform Debugging
- Digital Communication Protocols

---

## Applications

- Embedded Systems
- FPGA Design
- Sensor Interfaces
- Flash Memory Communication
- ADC/DAC Interfaces
- Industrial Automation
- Microcontroller Communication

---

## Future Improvements

- Support SPI Modes (Mode 0–3)
- Configurable Clock Divider
- Variable Data Width
- Multiple Slave Support
- FIFO Buffer Integration
- Error Detection Mechanism
- Randomized Verification Testbench

---

## Results

✅ SPI Master and Slave successfully communicate.

✅ All 5 verification test cases passed.

✅ Correct MOSI and MISO data transfer observed.

✅ Behavioral simulation completed successfully.

---

## Author

**Narasimha Lakkimsetty**

B.Tech – Electronics and Communication Engineering (ECE)

### Areas of Interest

- VLSI Design
- RTL Design
- Digital Verification
- FPGA Development
- ASIC Design
- Embedded Systems

---

⭐ If you found this project useful, consider giving this repository a Star!
