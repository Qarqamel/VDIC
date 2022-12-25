
class operation_transaction extends uvm_transaction;
    `uvm_object_utils(operation_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

	rand single_op_input_t sin_op_in;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
	
	constraint data {
		sin_op_in.arg_number dist {[2 : 10] := 1};
	}
	
//    constraint data {
//        A dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
//        B dist {8'h00:=2, [8'h01 : 8'hFE]:=1, 8'hFF:=2};
//    }
    
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        operation_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")
        
        sin_op_in = copied_transaction_h.sin_op_in;
        
//        A  = copied_transaction_h.A;
//        B  = copied_transaction_h.B;
//        op = copied_transaction_h.op;

    endfunction : do_copy


    function operation_transaction clone_me();
        
        operation_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        operation_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.sin_op_in == sin_op_in);
        
//            (compared_transaction_h.A == A) &&
//            (compared_transaction_h.B == B) &&
//            (compared_transaction_h.op == op);

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
        s = $sformatf("Data: %h Cmd: %s", sin_op_in.data, sin_op_in.cmd.name());
        return s;
    endfunction : convert2string

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : operation_transaction
