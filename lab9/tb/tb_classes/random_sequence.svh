class random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(random_sequence)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "random_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_RANDOM","",UVM_MEDIUM)
        `uvm_create(req);
        repeat (500) begin
	        `uvm_rand_send(req);
        end
    endtask : body

endclass : random_sequence
