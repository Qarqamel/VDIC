
class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// testbench elements
//------------------------------------------------------------------------------
    tester tester_h;
	driver driver_h;
	uvm_tlm_fifo #(operation_transaction) operation_f;
	
    coverage coverage_h;
    scoreboard scoreboard_h;
	operation_monitor operation_monitor_h;
    result_monitor result_monitor_h;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
	    operation_f  			= new("operation_f", this);
	    
        tester_h     			= tester::type_id::create("tester_h",this);
	    driver_h	 			= driver::type_id::create("driver_h",this);
        coverage_h   			= coverage::type_id::create ("coverage_h",this);
        scoreboard_h 			= scoreboard::type_id::create("scoreboard_h",this);
	    operation_monitor_h 	= operation_monitor::type_id::create("operation_monitor_h",this);
        result_monitor_h  		= result_monitor::type_id::create("result_monitor_h",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        driver_h.operation_in_port.connect(operation_f.get_export);
        tester_h.operation_in_port.connect(operation_f.put_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
        operation_monitor_h.ap.connect(scoreboard_h.op_in.analysis_export);
        operation_monitor_h.ap.connect(coverage_h.analysis_export);
    endfunction : connect_phase

endclass


