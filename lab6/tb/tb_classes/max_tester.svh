
class max_tester extends random_tester;
    `uvm_component_utils(max_tester)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
   
//------------------------------------------------------------------------------
// function: get_input - generate random input data for the tester
//------------------------------------------------------------------------------

	protected function single_op_input_t get_input();
		single_op_input_t ret_data;
		// for now only use correct parity input data
		case ($urandom_range(10, 0))
			0: ret_data.parity = parity_wrong;
			default: ret_data.parity = parity_correct;
		endcase
		// only valid nr of args
		ret_data.arg_number = arg_num_t'($urandom_range(10,2));
	
		case ($urandom_range(1, 0))
			0: ret_data.data_val = all_zeros;
			1: ret_data.data_val = all_ones;
			default: ret_data.data_val = random;
		endcase
		
		ret_data.cmd = get_cmd();
		
		for(int i = 0; i < ret_data.arg_number; i++) begin
			ret_data.data[(i*10)+:10] = get_data(ret_data.data_val, ret_data.parity);
		end
		
		return ret_data;
	endfunction : get_input

endclass : max_tester

