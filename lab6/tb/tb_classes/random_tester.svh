
class random_tester extends tester;
    `uvm_component_utils (random_tester)
    
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
	
		case ($urandom_range(3, 0))
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

	protected function command_t get_cmd();
		bit [2:0] cmd_choice;
		cmd_choice = 3'($random);
		case (cmd_choice)
			3'b000 : return cmd_nop;
			3'b001 : return cmd_and;
			3'b010 : return cmd_or;
			3'b011 : return cmd_xor;
			3'b100 : return cmd_add;
			3'b101 : return cmd_sub;
			3'b110 : return cmd_inv;
			3'b111 : return cmd_rst;
		endcase
	endfunction : get_cmd
	
	protected function bit [9:0] get_data(data_value_t dat_val, parity_t par);
		bit [9:0] data;
	    bit [1:0] zero_ones;
		data[9] = 0;
		case(dat_val)
			random: begin
			    zero_ones = 2'($random);
			    if (zero_ones == 2'b00)
			        data[8:1] = 8'h00;
			    else if (zero_ones == 2'b11)
			        data[8:1] = 8'hFF;
			    else
			        data[8:1] =  8'($random);
			end
			all_zeros: data[8:1] = 8'h00;
			all_ones: data[8:1] = 8'hFF;
		endcase
		case(par)
			parity_correct: data[0] = ^data[9:1];
			parity_wrong: data[0] = ~(^data[9:1]);
		endcase
	    return data;
	endfunction

endclass : random_tester






