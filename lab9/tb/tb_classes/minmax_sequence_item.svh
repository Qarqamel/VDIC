class minmax_sequence_item extends sequence_item;
    `uvm_object_utils(minmax_sequence_item)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint max_min_only {sin_op_in.data dist {80'h0 := 1, 80'hFFFFFFFFFFFFFFFFFFFF := 1};}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "minmax_sequence_item");
        super.new(name);
    endfunction : new

endclass : minmax_sequence_item