class max_transaction extends operation_transaction;
    `uvm_object_utils(max_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint max_min_only {sin_op_in.data_val dist {all_zeros := 2, all_ones := 2};}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : max_transaction


