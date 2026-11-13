class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)

  fifo_driver    drv;
  fifo_sequencer sqr;
  fifo_monitor   mon;
  fifo_config    cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction 
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(fifo_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "fifo_agent khong lay duoc cfg")

    is_active = cfg.is_active;                 // field co san trong uvm_agent

    mon = fifo_monitor::type_id::create("mon", this);      // lun tao monitor

    if (is_active == UVM_ACTIVE) begin                      // chi tao khi ACTIVE
      drv = fifo_driver   ::type_id::create("drv", this);
      sqr = fifo_sequencer::type_id::create("sqr", this);
    end
  endfunction 

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction 

endclass 