
class operation_monitor extends uvm_component;
    `uvm_component_utils(operation_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    uvm_analysis_port #(operation_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(single_op_input_t cmd);
	    operation_transaction op_tr;
        `ifdef DEBUG
        $display("COMMAND MONITOR: Data:0x%2h op: %s", cmd.data, cmd.cmd.name());
        `endif
        op_tr = new("op_tr");
        op_tr.sin_op_in = cmd;
        ap.write(op_tr);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
	    
	    alu_agent_config agent_config_h;

        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", agent_config_h))
            `uvm_fatal("COMMAND MONITOR", "Failed to get CONFIG");
        agent_config_h.bfm.operation_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase

endclass : operation_monitor
