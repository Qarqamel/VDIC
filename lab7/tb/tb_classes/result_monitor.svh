
class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    uvm_analysis_port #(result_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(result_t r);
	    result_transaction res;
        `ifdef DEBUG
        $display ("RESULT MONITOR: resultA: 0x%0h",r.data);
        `endif
        res.result = r;
        ap.write(res);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("RESULT MONITOR", "Failed to get BFM")
        bfm.result_monitor_h = this;
        ap                   = new("ap",this);
    endfunction : build_phase

endclass : result_monitor
