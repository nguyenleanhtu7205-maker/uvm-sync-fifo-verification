`uvm_analysis_imp_decl(_item)

class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp_item #(fifo_item, fifo_scoreboard) item_imp;

  // ---- REFERENCE MODEL ----
  bit [7:0]    ref_q [$];
  int unsigned DEPTH = 16;

  // ---- Thong ke ----
  int unsigned n_tr;
  int unsigned n_write, n_read, n_overflow, n_underflow;
  int unsigned n_pass, n_fail;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_imp = new("item_imp", this);
  endfunction

  virtual function void write_item(fifo_item tr);
    bit       exp_full, exp_empty;
    bit [7:0] exp_data;

    n_tr++;

    // (1) Trang thai model truoc khi cap nhat
    exp_full  = (ref_q.size() == DEPTH);
    exp_empty = (ref_q.size() == 0);

    // (2) So flag DUT voi model
    if (tr.full !== exp_full) begin
      n_fail++;
      `uvm_error("SB_FLAG", $sformatf(
        "tr#%0d FULL sai: DUT=%0b, model=%0b (size=%0d) | %s",
        n_tr, tr.full, exp_full, ref_q.size(), tr.convert2string()))
    end
    if (tr.empty !== exp_empty) begin
      n_fail++;
      `uvm_error("SB_FLAG", $sformatf(
        "tr#%0d EMPTY sai: DUT=%0b, model=%0b (size=%0d) | %s",
        n_tr, tr.empty, exp_empty, ref_q.size(), tr.convert2string()))
    end

    // (3) ĐOC truoc
    if (tr.rd_en) begin
      if (exp_empty) begin
        n_underflow++;
        `uvm_info("SB_UF", $sformatf("tr#%0d doc khi EMPTY - bo qua", n_tr), UVM_MEDIUM)
      end
      else begin
        exp_data = ref_q.pop_front();
        n_read++;
        if (tr.dout !== exp_data) begin
          n_fail++;
          `uvm_error("SB_DATA", $sformatf(
            "tr#%0d DATA MISMATCH: expected=0x%02h, actual=0x%02h (lan doc thu %0d)",
            n_tr, exp_data, tr.dout, n_read))
        end
        else begin
          n_pass++;
          `uvm_info("SB_DATA", $sformatf("tr#%0d MATCH: 0x%02h", n_tr, exp_data), UVM_HIGH)
        end
      end
    end

    // (4) GHI sau
    if (tr.wr_en) begin
      if (exp_full) begin
        n_overflow++;
        `uvm_info("SB_OF", $sformatf("tr#%0d ghi khi FULL - bo qua", n_tr), UVM_MEDIUM)
      end
      else begin
        ref_q.push_back(tr.din);
        n_write++;
      end
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (n_read == 0)
      `uvm_warning("SB_CHK", "Khong co lenh doc nao - test khong kiem tra duoc du lieu")
  endfunction

  function void report_phase(uvm_phase phase);
    string s;
    super.report_phase(phase);
    s = "\n=========== SCOREBOARD SUMMARY ===========\n";
    s = {s, $sformatf("  Writes accepted  : %0d\n", n_write)};
    s = {s, $sformatf("  Reads  checked   : %0d\n", n_read)};
    s = {s, $sformatf("  Overflow events  : %0d\n", n_overflow)};
    s = {s, $sformatf("  Underflow events : %0d\n", n_underflow)};
    s = {s, $sformatf("  Data matches     : %0d\n", n_pass)};
    s = {s, $sformatf("  Errors           : %0d\n", n_fail)};
    s = {s, "==========================================\n"};
    `uvm_info("SB_RPT", s, UVM_NONE)
  endfunction
endclass