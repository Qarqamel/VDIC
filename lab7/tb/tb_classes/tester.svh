
class tester extends uvm_component;
	`uvm_component_utils (tester)
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------

    uvm_put_port #(operation_transaction) operation_in_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

	function void build_phase(uvm_phase phase);
        operation_in_port = new("operation_in_port", this);
	endfunction : build_phase
	
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	
	task run_phase(uvm_phase phase);
		
		operation_transaction op_in;
		
		phase.raise_objection(this);
		
		op_in    = new("op_in");
		op_in.sin_op_in.cmd = cmd_rst;
        operation_in_port.put(op_in);
		
        op_in    = operation_transaction::type_id::create("op_in");
        repeat (1000) begin
            assert(op_in.randomize());
            operation_in_port.put(op_in);
        end
        #500;
        phase.drop_objection(this);
	    		
	endtask
	
endclass
