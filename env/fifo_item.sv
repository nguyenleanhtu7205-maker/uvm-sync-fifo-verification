class fifo_item extends uvm_sequence_item;
  rand bit          wr_en;
  rand bit          rd_en;
  rand bit [7:0]    din;
  rand int unsigned delay;

  bit [7:0]         dout;
  bit               full;
  bit               empty;

  `uvm_object_utils_begin(fifo_item)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(rd_en, UVM_ALL_ON)
    `uvm_field_int(din, UVM_ALL_ON  | UVM_HEX)
    `uvm_field_int(dout, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(full, UVM_ALL_ON)
    `uvm_field_int(empty, UVM_ALL_ON)
    `uvm_field_int(delay, UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end 

  function new (string name = "fifo_item");
    super.new(name);
  endfunction 

  constraint c_delay {delay inside {[0:3]};}
  constraint c_valid { !(wr_en == 0 && rd_en == 0);}
  constraint c_dist  { 
    {wr_en, rd_en} dist {2'b10 := 45, 2'b01 := 45, 2'b11 := 10};
  }

  virtual function string convert2string();
    return $sformatf("wr = %0b | rd = %0b | din = 0x%02h | dout = 0x%02h | full = %0b | empty = %0b",
                      wr_en, rd_en, din, dout, full, empty);
    
  endfunction

endclass 

class fifo_item_wr_only extends fifo_item;
  `uvm_object_utils(fifo_item_wr_only)

  function new(string name = "fifo_item_wr_only");
    super.new(name);
  endfunction

  constraint c_wr_only { wr_en == 1; rd_en == 0; }
endclass