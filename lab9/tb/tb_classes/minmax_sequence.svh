class minmax_sequence extends uvm_sequence #(minmax_sequence_item);
    `uvm_object_utils(minmax_sequence)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        repeat (500) begin
            `uvm_do(req);
        end
    endtask : body

endclass : minmax_sequence
