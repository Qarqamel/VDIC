class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

//------------------------------------------------------------------------------
// configuration object
//------------------------------------------------------------------------------

    alu_agent_config agent_config_h;

//------------------------------------------------------------------------------
// testbench components
//------------------------------------------------------------------------------

    tester tester_h;
    driver driver_h;
    scoreboard scoreboard_h;
    coverage coverage_h;
    operation_monitor operation_monitor_h;
    result_monitor result_monitor_h;

    uvm_tlm_fifo #(operation_transaction) operation_f;
    uvm_analysis_port #(operation_transaction) op_mon_ap;
    uvm_analysis_port #(result_transaction) result_ap;

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

        // get the agent configuration
        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", agent_config_h))
            `uvm_fatal("AGENT", "Failed to get config object");

        if (agent_config_h.get_is_active() == UVM_ACTIVE) begin : make_stimulus
            operation_f = new("operation_f", this);
            tester_h  = tester::type_id::create( "tester_h",this);
            driver_h  = driver::type_id::create("driver_h",this);
        end

        operation_monitor_h = operation_monitor::type_id::create("operation_monitor_h",this);
        result_monitor_h  = result_monitor::type_id::create("result_monitor_h",this);

        coverage_h        = coverage::type_id::create("coverage_h",this);
        scoreboard_h      = scoreboard::type_id::create("scoreboard_h",this);

        op_mon_ap        = new("op_mon_ap",this);
        result_ap         = new("result_ap", this);

    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        if (agent_config_h.get_is_active() == UVM_ACTIVE) begin : make_stimulus
            driver_h.operation_in_port.connect(operation_f.get_export);
            tester_h.operation_in_port.connect(operation_f.put_export);
        end

        operation_monitor_h.ap.connect(op_mon_ap);
        result_monitor_h.ap.connect(result_ap);

        operation_monitor_h.ap.connect(scoreboard_h.op_in.analysis_export);
        operation_monitor_h.ap.connect(coverage_h.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);

    endfunction : connect_phase


endclass : alu_agent
