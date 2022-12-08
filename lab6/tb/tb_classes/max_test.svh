
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

        // set the factory to produce a add_tester whenever it would produce
        // a random_tester
        random_tester::type_id::set_type_override(max_tester::get_type());

    endfunction : build_phase


endclass
