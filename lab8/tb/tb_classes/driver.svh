
class driver extends uvm_component;
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    uvm_get_port #(operation_transaction) operation_in_port;
    
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
	    alu_agent_config alu_agent_config_h;
        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
        	`uvm_fatal("DRIVER", "Failed to get config");
        bfm = alu_agent_config_h.bfm;
        operation_in_port = new("operation_in_port",this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        operation_transaction op_in;

        forever begin : command_loop
            operation_in_port.get(op_in);
            bfm.send_op(op_in.sin_op_in);
        end : command_loop
    endtask : run_phase
    

endclass : driver
