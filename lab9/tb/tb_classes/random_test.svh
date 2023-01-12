class random_test extends alu_base_test;
   `uvm_component_utils(random_test)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

   task run_phase(uvm_phase phase);
      random_sequence random;
      random = new("minimaxi");

      phase.raise_objection(this);
      random.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass
