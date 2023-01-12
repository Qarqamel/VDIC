class random_sequence_item extends sequence_item;
    `uvm_object_utils(random_sequence_item)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "random_sequence_item");
        super.new(name);
    endfunction : new

endclass : random_sequence_item