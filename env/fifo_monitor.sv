class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  virtual fifo_if vif;
  uvm_analysis_port #(fifo_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"vif khong duoc set cho ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    fifo_item tr;
    fifo_item pend_tr;
    bit       rd_pending = 0;

    forever begin
      @(vif.mon_cb);

      if (!vif.rst_n) begin
        rd_pending = 0;
        continue;
      end

      // (A) dout cua lenh o chu ki truoc gio moi hop le
      if (rd_pending) begin
        pend_tr.dout = vif.mon_cb.dout;
        `uvm_info(get_type_name(), $sformatf("MON: %s", pend_tr.convert2string()), UVM_HIGH)
        ap.write(pend_tr);
        rd_pending = 0;
      end

      // (B) phat hien hoat dong c=o chu ky nay
      if (vif.mon_cb.wr_en || vif.mon_cb.rd_en) begin
        tr = fifo_item::type_id::create("tr");   
        tr.wr_en = vif.mon_cb.wr_en;
        tr.rd_en = vif.mon_cb.rd_en;
        tr.din   = vif.mon_cb.din;
        tr.full  = vif.mon_cb.full;
        tr.empty = vif.mon_cb.empty;

        if (tr.rd_en && !tr.empty) begin
          pend_tr    = tr;        // doc hop le, cho chu ki sau lay dout
          rd_pending = 1;
        end
        else begin
          `uvm_info(get_type_name(), $sformatf("MON: %s", tr.convert2string()), UVM_HIGH)
          ap.write(tr);           
        end
      end
    end
  endtask
endclass