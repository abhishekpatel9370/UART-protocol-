# UART Protocol Implementation in Verilog

## 📜 Project Description

This project implements a simple **UART (Universal Asynchronous Receiver Transmitter)** protocol using Verilog HDL.  
It consists of a **UART Transmitter** (`uart_tx`) and a **UART Receiver** (`uart_rx`), connected in a loopback configuration and tested using **VIO** (Virtual Input/Output) and **ILA** (Integrated Logic Analyzer) IP cores on an FPGA.

## ✨ Features

- ✅ **UART Transmitter**
  - Sends 8-bit serial data
  - Includes start bit, 8 data bits, and stop bit
  - Provides `tx_busy` and `tx_done` signals for handshake/monitoring
- ✅ **UART Receiver**
  - Receives 8-bit serial data
  - Detects start bit and stop bit
  - Provides `rx_data` and `rx_done` signals
- ✅ **Loopback Test**
  - Transmitter output (`tx`) is connected to Receiver input (`rx`)
  - Verified using VIO & ILA in Vivado

## 🗂 Project Structure

├── uart_tx.v # UART Transmitter Module
├── uart_rx.v # UART Receiver Module
├── uart_top.v # Top module with VIO & ILA instances for testing
└── README.md # Project README

markdown
Copy
Edit

## 🖥️ How it Works

### UART TX (Transmitter)

- Waits for `tx_start` pulse from VIO.
- Loads data from `tx_data[7:0]`.
- Sends Start bit (`0`), 8 Data bits, Stop bit (`1`) serially over `tx`.
- Provides:
  - `tx_busy` → High during transmission
  - `tx_done` → Single clock pulse after transmission completes

### UART RX (Receiver)

- Waits for Start bit (`0`) on `rx` line.
- Samples each Data bit in middle of bit duration.
- Assembles received byte into `rx_data`.
- Provides:
  - `rx_done` → Single clock pulse when valid byte is received.

### Testing with VIO + ILA

- VIO is used to:
  - Provide `tx_start` signal
  - Provide `tx_data`
- ILA is used to:
  - Monitor `tx_start`, `tx_data`, `tx`, `tx_busy`, `tx_done`
  - Monitor `rx`, `rx_data`, `rx_done`
- Loopback connection: `tx` → `rx`

## 🛠️ Parameters

- `CLKS_PER_BIT` → Defines baud rate based on your FPGA clock:
  - Example: 10 MHz clock and 19200 baud → `CLKS_PER_BIT = 5208`

Adjust this value depending on your FPGA clock frequency.

