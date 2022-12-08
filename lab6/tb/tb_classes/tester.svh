
virtual class tester extends uvm_component;

//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------

    uvm_put_port #(single_op_input_t) operation_in_port;

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

	protected virtual alu_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function single_op_input_t get_input();

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

	function void build_phase(uvm_phase phase);
        operation_in_port = new("operation_in_port", this);
	endfunction : build_phase
	
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	
	task run_phase(uvm_phase phase);
		
		single_op_input_t op_in;
		
		phase.raise_objection(this);
		op_in.cmd = cmd_rst;
		operation_in_port.put(op_in);
	    repeat (1000) begin : tester_main
		    op_in = get_input();
		    operation_in_port.put(op_in);
	    end : tester_main
	    #500;
        phase.drop_objection(this);
	    
//	    bfm.reset_alu();
//		repeat (1000) begin : tester_main
//			
//			@(negedge bfm.clk);
//			
//			bfm.output_rcvd_flag = 0;
//			bfm.single_op_input = get_input();
//		
//			case(bfm.single_op_input.cmd)
//				cmd_rst: begin
//					bfm.reset_alu();
//				end
//				cmd_nop: begin	
//					for(int i = 0; i < bfm.single_op_input.arg_number; i++) begin
//						bfm.send_word(bfm.single_op_input.data[(i*10)+:10]);	
//					end
//					bfm.send_word(bfm.single_op_input.cmd);
//				end
//				default: begin	
//					for(int i = 0; i < bfm.single_op_input.arg_number; i++) begin
//						bfm.send_word(bfm.single_op_input.data[(i*10)+:10]);	
//					end
//					bfm.send_word(bfm.single_op_input.cmd);
//					
//					bfm.receive_word(bfm.output_status);
//					bfm.receive_word(bfm.output_data[19:10]);
//					bfm.receive_word(bfm.output_data[9:0]);
//					
//					bfm.output_rcvd_flag = 1;
//					
//				end
//			endcase		
//		end : tester_main
//		
//		phase.drop_objection(this);
		
	endtask
	
endclass
