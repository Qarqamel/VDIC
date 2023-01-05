
class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// agents
//------------------------------------------------------------------------------

    alu_agent class_alu_agent_h;
    alu_agent module_alu_agent_h;

//------------------------------------------------------------------------------
// testbench elements
//------------------------------------------------------------------------------
//    tester tester_h;
//	driver driver_h;
//	uvm_tlm_fifo #(operation_transaction) operation_f;
//	
//    coverage coverage_h;
//    scoreboard scoreboard_h;
//	operation_monitor operation_monitor_h;
//    result_monitor result_monitor_h;

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

        // declare configuration object handlers
        env_config env_config_h;
        alu_agent_config class_agent_config_h;
        alu_agent_config module_agent_config_h;

        // get the env_config with two BFM's included
        if(!uvm_config_db #(env_config)::get(this, "","config", env_config_h))
            `uvm_fatal("ENV", "Failed to get config object");

        // create configs for the agents
        class_agent_config_h   = new(.bfm(env_config_h.class_bfm), .is_active(UVM_ACTIVE));
        
        // for the second DUT we provide external stimulus, the agent does not generate it
        module_agent_config_h  = new(.bfm(env_config_h.module_bfm), .is_active(UVM_PASSIVE));

        // store the agent configs in the UMV database
        // important: restricted access by the hierarchical name, the second argument must
        //            match the agent handler name
        uvm_config_db #(alu_agent_config)::set(this, "class_alu_agent_h*",
            "config", class_agent_config_h);
        uvm_config_db #(alu_agent_config)::set(this, "module_alu_agent_h*",
            "config", module_agent_config_h);

        // create the agents
        class_alu_agent_h  = alu_agent::type_id::create("class_alu_agent_h",this);
        module_alu_agent_h = alu_agent::type_id::create("module_alu_agent_h",this);

    endfunction : build_phase

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
//    function void build_phase(uvm_phase phase);
//	    operation_f  			= new("operation_f", this);
//	    
//        tester_h     			= tester::type_id::create("tester_h",this);
//	    driver_h	 			= driver::type_id::create("driver_h",this);
//        coverage_h   			= coverage::type_id::create ("coverage_h",this);
//        scoreboard_h 			= scoreboard::type_id::create("scoreboard_h",this);
//	    operation_monitor_h 	= operation_monitor::type_id::create("operation_monitor_h",this);
//        result_monitor_h  		= result_monitor::type_id::create("result_monitor_h",this);
//    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------
//    function void connect_phase(uvm_phase phase);
//        driver_h.operation_in_port.connect(operation_f.get_export);
//        tester_h.operation_in_port.connect(operation_f.put_export);
//        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
//        operation_monitor_h.ap.connect(scoreboard_h.op_in.analysis_export);
//        operation_monitor_h.ap.connect(coverage_h.analysis_export);
//    endfunction : connect_phase

endclass


