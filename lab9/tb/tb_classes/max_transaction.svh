class max_transaction extends operation_transaction;
    `uvm_object_utils(max_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint max_min_only {sin_op_in.data dist {80'h0 := 1, 80'hFFFFFFFFFFFFFFFFFFFF := 1};}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : max_transaction


