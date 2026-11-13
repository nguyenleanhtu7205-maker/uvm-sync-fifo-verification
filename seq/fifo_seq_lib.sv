class fifo_base_seq extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_base_seq)
  int unsigned num_trans = 20;

  function new (string name = "fifo_base_seq");
    super.new(name);
  endfunction

endclass 

// Chi ghi
class fifo_write_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_write_seq)
  
  function new(string name = "fifo_write_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_item tr;
    repeat(num_trans) begin
      tr = fifo_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {wr_en == 1; rd_en == 0; delay inside {[0:1]};})
      `uvm_error(get_type_name(), "randomize that bai")
      finish_item(tr); 
    end 
  endtask 

endclass 

//Chi doc
class fifo_read_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_read_seq)
  function new(string name = "fifo_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_item tr;
    repeat (num_trans) begin
      tr = fifo_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { wr_en == 0; rd_en == 1; delay inside {[0:1]}; })
        `uvm_error(get_type_name(), "randomize that bai")
      finish_item(tr);
    end
  endtask
endclass

//  Random mac dinh
class fifo_random_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_random_seq)
  function new(string name = "fifo_random_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_item tr;
    repeat (num_trans) begin
      tr = fifo_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize())
        `uvm_error(get_type_name(), "randomize that bai")
      finish_item(tr);
    end
  endtask
endclass

// overflow: ghi lien tuc depth+5 lan
class fifo_overflow_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_overflow_seq)
  function new(string name = "fifo_overflow_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_item tr;
    repeat (16 + 5) begin
      tr = fifo_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { wr_en == 1; rd_en == 0; delay == 0; })
        `uvm_error(get_type_name(), "randomize that bai")
      finish_item(tr);
    end
  endtask
endclass

// underflow: doc lien tuc depth+5 lan
class fifo_underflow_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_underflow_seq)
  function new(string name = "fifo_underflow_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_item tr;
    repeat (16 + 5) begin
      tr = fifo_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { wr_en == 0; rd_en == 1; delay == 0; })
        `uvm_error(get_type_name(), "randomize that bai")
      finish_item(tr);
    end
  endtask
endclass

//nesting
class fifo_full_then_empty_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_full_then_empty_seq)
  function new(string name = "fifo_full_then_empty_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_overflow_seq  wr_seq;
    fifo_underflow_seq rd_seq;
    wr_seq = fifo_overflow_seq ::type_id::create("wr_seq");
    rd_seq = fifo_underflow_seq::type_id::create("rd_seq");
    wr_seq.start(m_sequencer);
    rd_seq.start(m_sequencer);
  endtask
endclass

// wrap:quay vong con tro ma khong bao gio day
class fifo_wrap_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_wrap_seq)
  function new(string name = "fifo_wrap_seq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_write_seq wr_seq;
    fifo_read_seq  rd_seq;
    repeat (3) begin
      wr_seq = fifo_write_seq::type_id::create("wr_seq");
      rd_seq = fifo_read_seq ::type_id::create("rd_seq");
      wr_seq.num_trans = 10;
      rd_seq.num_trans = 10;
      wr_seq.start(m_sequencer);
      rd_seq.start(m_sequencer);
    end
  endtask
endclass