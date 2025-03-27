`timescale 1ns / 1ps
interface spi_if;

  logic clk;
  logic rst;
  logic newd;
  logic [11:0] din;
  logic [11:0] dout;
  logic done;
  logic sclk;
  logic cs;
  logic MOSI;

endinterface