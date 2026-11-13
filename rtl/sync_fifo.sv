//==========================================================
// File: sync_fifo.sv   — DUT
//==========================================================
module sync_fifo #(
  parameter int DWIDTH = 8, 
  parameter int DEPTH = 16
) (
  input   logic               clk, 
  input   logic               rst_n, 
  input   logic               wr_en, 
  input   logic[DWIDTH-1 : 0] din, 
  input   logic               rd_en, 
  output  logic[DWIDTH-1 : 0] dout, 
  output  logic               full, 
  output  logic               empty);
  
  localparam int AW = $clog2(DEPTH);
  
  logic[DWIDTH-1 : 0] mem[DEPTH];
  logic[AW-1 : 0]     wr_ptr, rd_ptr;
  logic[AW:0]         count; // can them 1 bit de bieu dien gia tri DEPTH
  
  assign full   = (count == DEPTH);
  assign empty  = (count == 0);
  
  // ---- Write path ----
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      wr_ptr <= '0;
    end
    else if (wr_en && !full) begin
      mem[wr_ptr] <= din;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end
  
  // ---- Read path (synchronous read) ----
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rd_ptr <= '0;
      dout <= '0;
    end
    else if (rd_en && !empty) begin
      dout <= mem[rd_ptr];
      rd_ptr <= rd_ptr + 1'b1;
    end
  end
  
  // ---- Occupancy counter ----
  always_ff @(posedge clk) begin
    if (!rst_n)
      count <= '0;
    else begin
      case ({(wr_en && !full), (rd_en && !empty)})
        2'b10: count <= count + 1'b1; // Chi ghi
        2'b01: count <= count - 1'b1; // Chi doc
        default: count <= count; // Khong gi, hoac ghi doc dong thoi
      endcase
    end
  end
  
endmodule