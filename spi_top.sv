`timescale 1ns / 1ps

`include "spi_master.sv"
`include "spi_slave.sv"
`include "spi_if"

module top(
  input clk,rst,newd,
  input [11:0] din,
  output done,
  output bit[11:0] dout);
  wire sclk,MOSI,cs;
  
  spi_master m1(clk,rst,newd,din,cs,MOSI,sclk);
  spi_slave s1(sclk,MOSI,cs,dout,done);
  
endmodule
  