
class operation_monitor extends uvm_component;
    `uvm_component_utils(operation_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    local virtual alu_bfm bfm;
    uvm_analysis_port #(sequence_item) ap;

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
	    sequence_item op_tr;
        `ifdef DEBUG
        $display("COMMAND MONITOR: Data:0x%2h op: %s", cmd.data, cmd.cmd.name());
        `endif
        op_tr = new("op_tr");
        op_tr.sin_op_in = cmd;
        ap.write(op_tr);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        bfm.operation_monitor_h = this;
    endfunction : connect_phase

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
	        `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        
        ap                    = new("ap",this);
    endfunction : build_phase

endclass : operation_monitor
