class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)

  fifo_env    env;
  fifo_config cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    cfg.is_active     = UVM_ACTIVE;
    cfg.num_trans     = 20;
    cfg.en_scoreboard = 1;
    cfg.en_coverage   = 1;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = fifo_config::type_id::create("cfg");
    configure_cfg();
    uvm_config_db #(fifo_config)::set(this, "env*", "cfg", cfg);
    env = fifo_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  // hook kich ban, mac dinh test random
  virtual task run_scenario();
    fifo_random_seq seq;
    seq = fifo_random_seq::type_id::create("seq");
    seq.num_trans = cfg.num_trans;
    seq.start(env.agt.sqr);
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, {get_type_name(), " started"});
    if (cfg.is_active == UVM_ACTIVE)
      run_scenario();                         
    else begin
      `uvm_info("TEST", "Agent PASSIVE: khong lai tin hieu", UVM_LOW)
      #500ns;
    end
    #100ns;
    phase.drop_objection(this, {get_type_name(), " finished"});
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server svr = uvm_report_server::get_server();
    super.report_phase(phase);
    if (svr.get_severity_count(UVM_ERROR) == 0 && svr.get_severity_count(UVM_FATAL) == 0)
      `uvm_info("RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction
endclass

// ---------- 1. Ghi roi doc ----------
class fifo_write_read_test extends fifo_base_test;
  `uvm_component_utils(fifo_write_read_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_scenario();
    fifo_write_seq wseq;
    fifo_read_seq  rseq;
    wseq = fifo_write_seq::type_id::create("wseq");
    rseq = fifo_read_seq ::type_id::create("rseq");
    wseq.num_trans = 10;
    rseq.num_trans = 10;
    wseq.start(env.agt.sqr);
    rseq.start(env.agt.sqr);
  endtask
endclass

// ---------- 2. Random stress ----------
class fifo_random_test extends fifo_base_test;
  `uvm_component_utils(fifo_random_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void configure_cfg();
    super.configure_cfg();
    cfg.num_trans = 1000;
  endfunction
endclass

// ---------- 3. Corner: overflow + underflow, lap 5 lan ----------
class fifo_corner_test extends fifo_base_test;
  `uvm_component_utils(fifo_corner_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_scenario();
    fifo_full_then_empty_seq seq;
    seq = fifo_full_then_empty_seq::type_id::create("seq");
    repeat (5) seq.start(env.agt.sqr);
  endtask
endclass

// ---------- 4. Factory override: chi sinh transaction ghi ----------
class fifo_wr_only_test extends fifo_base_test;
  `uvm_component_utils(fifo_wr_only_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(fifo_item::get_type(), fifo_item_wr_only::get_type());
    super.build_phase(phase);              
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_factory::get().print();            // xac nhan override co hieu luc
  endfunction
endclass

// ---------- 5. Wrap-around con tro (bo sung de dung fifo_wrap_seq) ----------
class fifo_wrap_test extends fifo_base_test;
  `uvm_component_utils(fifo_wrap_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_scenario();
    fifo_wrap_seq seq;
    seq = fifo_wrap_seq::type_id::create("seq");
    seq.start(env.agt.sqr);
  endtask
endclass