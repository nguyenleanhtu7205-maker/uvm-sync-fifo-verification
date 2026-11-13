class fifo_coverage extends uvm_subscriber #(fifo_item);
  `uvm_component_utils(fifo_coverage)

  fifo_item tr_h;      // transaction dang duoc lay mau

  covergroup cg_fifo;
    option.per_instance = 1;

    // 1. Loai thao tac (map F01, F07)
    cp_op : coverpoint {tr_h.wr_en, tr_h.rd_en} {
      bins write_only   = {2'b10};
      bins read_only    = {2'b01};
      bins both         = {2'b11};
      illegal_bins none = {2'b00};
    }

    // 2. Trang thai FIFO luc thao tac (map F03, F04)
    cp_full  : coverpoint tr_h.full;
    cp_empty : coverpoint tr_h.empty;

    // 3. Gia tri data, chia giai de tranh 256 bin
    cp_din : coverpoint tr_h.din iff (tr_h.wr_en) {
      bins zero     = {8'h00};
      bins low      = {[8'h01:8'h3F]};
      bins mid      = {[8'h40:8'hBF]};
      bins high     = {[8'hC0:8'hFE]};
      bins all_ones = {8'hFF};
    }

    // 4. CROSS
    cx_op_full : cross cp_op, cp_full {
      bins write_when_full = binsof(cp_op.write_only) && binsof(cp_full) intersect {1};
      bins both_when_full  = binsof(cp_op.both)       && binsof(cp_full) intersect {1};
    }
    cx_op_empty : cross cp_op, cp_empty {
      bins read_when_empty = binsof(cp_op.read_only) && binsof(cp_empty) intersect {1};
      bins both_when_empty = binsof(cp_op.both)      && binsof(cp_empty) intersect {1};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_fifo = new();                  // covergroup trong class PHAI new() o constructor
  endfunction

  // uvm_subscriber da co san analysis_export, ta chi hien thuc write()
  virtual function void write(fifo_item t);
    tr_h = t;
    cg_fifo.sample();
  endfunction

  // DIEU CHINH: in % tung phan
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("TONG        = %5.1f%%", cg_fifo.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("cp_op       = %5.1f%%", cg_fifo.cp_op.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("cp_full     = %5.1f%%", cg_fifo.cp_full.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("cp_empty    = %5.1f%%", cg_fifo.cp_empty.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("cp_din      = %5.1f%%", cg_fifo.cp_din.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("cx_op_full  = %5.1f%%", cg_fifo.cx_op_full.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("cx_op_empty = %5.1f%%", cg_fifo.cx_op_empty.get_inst_coverage()), UVM_NONE)
  endfunction
endclass