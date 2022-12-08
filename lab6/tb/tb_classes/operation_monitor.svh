
class operation_monitor extends uvm_component;
    `uvm_component_utils(operation_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    uvm_analysis_port #(single_op_input_t) ap;

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
        `ifdef DEBUG
        $display("COMMAND MONITOR: Data:0x%2h op: %s", cmd.data, cmd.cmd.name());
        `endif
        ap.write(cmd);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        bfm.operation_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase

endclass : operation_monitor
