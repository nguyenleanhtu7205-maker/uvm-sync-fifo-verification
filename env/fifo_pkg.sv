`timescale 1ns/1ps
package fifo_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "fifo_item.sv"
  `include "fifo_config.sv"
  `include "fifo_sequencer.sv"
  `include "fifo_seq_lib.sv"
  `include "fifo_driver.sv"
  `include "fifo_monitor.sv"
  `include "fifo_agent.sv"
  `include "fifo_scoreboard.sv"
  `include "fifo_coverage.sv" 
  `include "fifo_env.sv"
  `include "fifo_test_lib.sv"
endpackage