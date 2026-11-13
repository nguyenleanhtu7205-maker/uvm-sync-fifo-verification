interface fifo_if #(
  parameter int WIDTH = 8
)(
  input logic clk,
  input logic rst_n
);
  logic             wr_en;
  logic             rd_en;
  logic [WIDTH-1:0] din;
  logic [WIDTH-1:0] dout;
  logic             full;
  logic             empty;

  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output wr_en, rd_en, din;
    input empty, full, dout;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input wr_en, rd_en, din, dout, empty, full;
  endclocking 
  
  modport DRV (clocking drv_cb, input rst_n);
  modport MON (clocking mon_cb, input rst_n);

endinterface