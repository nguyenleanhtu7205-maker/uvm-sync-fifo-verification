class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent      agt;
  fifo_scoreboard sb;
  fifo_coverage   cov;                         
  fifo_config     cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(fifo_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "fifo_env khong lay duoc cfg")

    uvm_config_db #(fifo_config)::set(this, "agt*", "cfg", cfg);

    agt = fifo_agent::type_id::create("agt", this);
    if (cfg.en_scoreboard)
      sb  = fifo_scoreboard::type_id::create("sb", this);
    if (cfg.en_coverage)                       
      cov = fifo_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.en_scoreboard)
      agt.mon.ap.connect(sb.item_imp);
    if (cfg.en_coverage)                      
      agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass