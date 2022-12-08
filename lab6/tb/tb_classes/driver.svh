class driver extends uvm_component;
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual alu_bfm bfm;
    uvm_get_port #(single_op_input_t) operation_in_port;
    
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
            $fatal(1, "Failed to get BFM");
        operation_in_port = new("operation_in_port",this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        single_op_input_t op_in;

        forever begin : command_loop
            operation_in_port.get(op_in);
            bfm.send_op(op_in);
        end : command_loop
    endtask : run_phase
    

endclass : driver
