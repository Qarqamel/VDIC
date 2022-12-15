
class max_test extends random_test;
    `uvm_component_utils(max_test)

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
        super.build_phase(phase);
        operation_transaction::type_id::set_type_override(max_transaction::get_type());
    endfunction : build_phase

endclass
