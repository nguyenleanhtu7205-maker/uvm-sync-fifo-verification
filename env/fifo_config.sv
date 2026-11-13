class fifo_config extends uvm_object;
  `uvm_object_utils(fifo_config)

  uvm_active_passive_enum is_active     = UVM_ACTIVE;
  int unsigned            num_trans     = 20;
  bit                     en_scoreboard = 1;
  bit                     en_coverage   = 1;

  function new(string name = "fifo_config");
    super.new(name);
  endfunction 

endclass 