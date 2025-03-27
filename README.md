# SPI_Protocol
The Serial Peripheral Interface (SPI) is a high-speed, full-duplex communication protocol widely used for interfacing microcontrollers, sensors, memory devices, and other peripherals. It follows a master-slave architecture, where the master initiates data transmission and controls the clock (SCLK). SPI uses four main signals:

MOSI (Master Out, Slave In) – Data sent from the master to the slave.

MISO (Master In, Slave Out) – Data sent from the slave to the master.

SCLK (Serial Clock) – Clock signal controlled by the master.

CS (Chip Select) – Enables communication with a specific slave device.

SPI supports multiple clock modes, configurable data frame sizes, and different bit transmission orders (MSB-first or LSB-first). Due to its simple and efficient hardware requirements, SPI is widely used in embedded systems and SoC designs.

Project Implementation
SPI Master Module: Developed using a finite state machine (FSM) to control data transmission.

Clock and Control Signals: Handles SCLK generation and chip select (CS) management for proper synchronization.

Data Transmission: Transmits 12-bit data (LSB-first) via the MOSI line.

Functional Verification: Implemented a testbench to verify protocol operation using:

Randomized Stimuli to test various scenarios.

Golden Data Comparison to ensure output correctness.

This project demonstrates a structured approach to SPI protocol design and verification, making it suitable for high-speed data communication in embedded systems.
