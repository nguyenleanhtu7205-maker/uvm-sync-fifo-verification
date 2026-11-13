`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import fifo_pkg::*;

  logic clk, rst_n;

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end 

  initial begin
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
    `uvm_info("TB_TOP", "Reset da nha", UVM_LOW)
  end 

  // ---- Interface & DUT ----
  fifo_if vif (.clk(clk), .rst_n(rst_n));

  sync_fifo #(.DWIDTH(8), .DEPTH(16)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(vif.wr_en),
    .rd_en(vif.rd_en),
    .din(vif.din),
    .dout(vif.dout),
    .full(vif.full),
    .empty(vif.empty)
  );


  // ---- UVM ----
  initial begin 
    uvm_config_db #(virtual fifo_if)::set(null, "*", "vif", vif);
    uvm_top.set_timeout(1ms, 1);
    run_test();
  end 

  // ---- Waveform ----
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_top);
  end 

endmodule 