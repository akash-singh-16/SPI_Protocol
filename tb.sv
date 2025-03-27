`timescale 1ns / 1ps
class transaction;
  bit newd;
  rand bit[11:0] din;
  bit [11:0] dout; 
  //bit done;
  
  function transaction copy();
    copy=new();
    copy.newd = this.newd;
    copy.din = this.din;
    copy.dout = this.dout;
    endfunction
  
endclass

class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  event done;
  int count=0;
  event drvnext;
  event sconext;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
    tr=new();
    endfunction
    
  task run();
    repeat(count)begin
      assert(tr.randomize) else $error("Randomization Failed");
      mbx.put(tr.copy);
      $display("[GEN] : Din = %0d",tr.din);
     // @(drvnext);
      @(sconext);
    end
    ->done;
  endtask

endclass

class driver;
  virtual spi_if vif;
  transaction tr;
  mailbox #(transaction) mbx;
  mailbox #(bit [11:0]) mbxds;
  event drvnext;
   bit[11:0] din;
  function new(mailbox #(bit [11:0]) mbxds,mailbox #(transaction) mbx);
    this.mbx=mbx;
    this.mbxds=mbxds;
  endfunction
 
  task reset();
    vif.rst<=1'b1;
    vif.newd<=1'b0;
    vif.din<=1'b0;
    repeat(5) @(posedge vif.clk);
      vif.rst<=1'b0;
    repeat(2) @(posedge vif.clk);
    $display("[DRV] : Reset Done");
    $display("--------------------------------------");
  endtask
  
  task run();
    forever begin
      mbx.get(tr);
     
      vif.newd<=1'b1;
      vif.din<=tr.din;
      mbxds.put(tr.din);
      @(posedge vif.sclk);
      vif.newd<=1'b0;
      @(posedge vif.done);
      $display("[DRV] : Data sent to DAC : %0d",tr.din);
      @(posedge vif.sclk);
     // ->drvnext;
    end
  endtask
endclass


class monitor;
  transaction tr;
  mailbox #(bit [11:0]) mbx;
  
  virtual spi_if vif;
  
  function new(mailbox #(bit[11:0]) mbx);
    this.mbx=mbx;
  endfunction
  
  task run();
    tr=new();
    forever begin;
      @(posedge vif.sclk);   
      @(posedge vif.done);
      tr.dout=vif.dout;
      @(posedge vif.sclk);
      $display("[MON] : Data Sent : %0d",tr.dout);
      mbx.put(tr.dout);
    end
    
  endtask
  
endclass

class scoreboard;
  mailbox #(bit[11:0]) mbxds;
  mailbox #(bit[11:0]) mbxms;
  bit[11:0] ds,ms;
  event sconext;
  
  function new(mailbox #(bit[11:0]) mbxds, mailbox#(bit[11:0]) mbxms);
    this.mbxds=mbxds;
    this.mbxms=mbxms;
  endfunction
  
  task run();
  forever begin
    mbxds.get(ds);
    mbxms.get(ms);
    $display("[SCO] : Driver Data : %0d and Monitor Data : %0d",ds,ms);
    if(ds==ms) $display("[SCO] : Data Matched");
    else $display("[SCO] : Data Mismatched");
    
    $display("--------------------------------------");
    ->sconext;
  end
  endtask
endclass

class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  event nextgd;
  event nextgs;
  
  mailbox #(transaction) mbxgd;
  mailbox #(bit[11:0]) mbxds;
  mailbox #(bit[11:0]) mbxms;
  
  virtual spi_if vif;
  
  function new(virtual spi_if vif);
    mbxgd=new();
    mbxds=new();
    mbxms=new();
    gen=new(mbxgd);
    drv=new(mbxds,mbxgd);
    mon=new(mbxms);
    sco=new(mbxds,mbxms);
    this.vif=vif;
    drv.vif=this.vif;
    mon.vif=this.vif;
    gen.sconext=nextgs;
    sco.sconext=nextgs;
    gen.drvnext=nextgd;
    drv.drvnext=nextgd;
       
  endfunction
  
    task pretest();
      drv.reset();
    endtask
    task test();
      fork 
        gen.run();
        drv.run();
        mon.run();
        sco.run();
      join_any
    endtask
    task posttest();
      wait(gen.done.triggered)
      $finish();
    endtask
    
    task run();
      pretest();
      test();
      posttest();
    endtask
 
  
endclass

module tb;
  spi_if vif();
  environment env;
  
  top dut(vif.clk,vif.rst,vif.newd,vif.din,vif.done,vif.dout);
  
  
  initial begin
    vif.clk<=0;
  end
  
  always #10 vif.clk<=~vif.clk;
  assign vif.sclk=dut.m1.sclk;
  initial begin
  env = new(vif);
  env.gen.count=20;
  env.run();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
    
  end
endmodule