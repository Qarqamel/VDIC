class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand single_op_input_t sin_op_in;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

//	`uvm_object_utils_begin(sequence_item)
//        `uvm_field_struct(sin_op_in, UVM_ALL_ON | UVM_DEC)
//    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

	constraint data {
		sin_op_in.arg_number dist {[2 : 10] := 1};
	}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        sequence_item copied_seq_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_seq_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")
        
        sin_op_in = copied_seq_h.sin_op_in;

    endfunction : do_copy


    function sequence_item clone_me();
        
        sequence_item clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        sequence_item compared_seq_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_seq_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_seq_h.sin_op_in == sin_op_in);

        return same;
        
    endfunction : do_compare

    function string convert2string();
        string s;
        s = $sformatf("Data: %h Cmd: %s", sin_op_in.data, sin_op_in.cmd.name());
        return s;
    endfunction : convert2string

endclass : sequence_item
