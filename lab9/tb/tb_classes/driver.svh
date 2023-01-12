
class driver extends uvm_driver #(sequence_item);
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    
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
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM")
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

	    sequence_item op_in;
	    void'(begin_tr(op_in));

        forever begin : command_loop
	        seq_item_port.get_next_item(op_in);
            bfm.send_op(op_in.sin_op_in);
	        seq_item_port.item_done();
        end : command_loop
    endtask : run_phase
    

endclass : driver
