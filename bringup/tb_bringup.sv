module tb_bringup;
  logic clk = 0;
  logic rst_n = 0;

  fifo_if #(.WIDTH(8)) vif (.clk(clk), .rst_n(rst_n));

  sync_fifo #(.WIDTH(8), .DEPTH(16)) dut (
    .wr_en(vif.wr_en),
    .rd_en(vif.rd_en),
    .din(vif.din),
    .dout(vif.dout),
    .empty(vif.empty),
    .full(vif.full),
    .clk(clk),
    .rst_n(rst_n)
  );

  always #5 clk = ~clk;

  int error = 0;

  task automatic check (string name, logic [7:0] got, logic [7:0] exp);
    if (got == exp) $display("[0%t] PASS %s: dout = %h", $time, name, got);
    else begin
      $display("[0%t] FAIL %s: dout = %h | expect = %h", $time, name, got, exp);
      error ++;
    end 
  endtask 

  initial begin
    $dumpfile("fifo_bringup.vcd");
    $dumpvars(0, tb_bringup);

    vif.drv_cb.wr_en <= 1'b0;
    vif.drv_cb.rd_en <= 1'b0;
    vif.drv_cb.din   <= '0;
    repeat (5) @(vif.drv_cb);
    rst_n = 1'b1;

    // ---- GHI AA, BB ----
    @(vif.drv_cb);  //Ghi AA
    vif.drv_cb.wr_en <= 1'b1;
    vif.drv_cb.din   <= 8'hAA;
    
    @(vif.drv_cb);  //Ghi BB
    vif.drv_cb.din   <= 8'hBB;

    @(vif.drv_cb);
    vif.drv_cb.wr_en <= 1'b0;

    repeat (2) @(vif.drv_cb);

    // ---- DOC 2 LAN ----
    vif.drv_cb.rd_en <= 1'b1;
    repeat (2) @(vif.drv_cb);
    check("read #1", vif.drv_cb.dout, 8'hAA);

    vif.drv_cb.rd_en <= 1'b0;
    @(vif.drv_cb);
    check ("read #2", vif.drv_cb.dout, 8'hBB);

    repeat (5) @(vif.drv_cb);

    if (error == 0) $display("==== BRINGUP PASS ====");
    else $display("==== BRINGUP FAIL: %0d error==== ", error);
    $finish;
  
  end 
  
endmodule