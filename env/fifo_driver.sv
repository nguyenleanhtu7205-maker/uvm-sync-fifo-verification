class fifo_driver extends uvm_driver #(fifo_item);
  `uvm_component_utils(fifo_driver)

  virtual fifo_if vif;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction 

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"vif khong duoc set cho", get_full_name()});
  endfunction 

  virtual task reset_signal();
    vif.drv_cb.wr_en <= 1'b0;
    vif.drv_cb.rd_en <= 1'b0;
    vif.drv_cb.din   <= '0;
  endtask 

  virtual task drive_one (fifo_item tr);
    repeat (tr.delay) begin
      vif.drv_cb.wr_en <= 1'b0;
      vif.drv_cb.rd_en <= 1'b0;
      @(vif.drv_cb);
    end 

    vif.drv_cb.wr_en <= tr.wr_en;
    vif.drv_cb.rd_en <= tr.rd_en;
    vif.drv_cb.din   <= tr.din;
    @(vif.drv_cb);
    vif.drv_cb.wr_en <= 1'b0;
    vif.drv_cb.rd_en <= 1'b0;
    `uvm_info(get_type_name(), $sformatf("DRIVE: %s", tr.convert2string()), UVM_HIGH)
  endtask 

  task run_phase (uvm_phase phase);
    reset_signal();
    wait(vif.rst_n === 1'b1);
    @(vif.drv_cb);
    forever begin
      seq_item_port.get_next_item(req);
      drive_one(req);
      seq_item_port.item_done();
    end 
  endtask 

endclass 