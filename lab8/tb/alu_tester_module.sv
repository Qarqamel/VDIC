module alu_tester_module(alu_bfm bfm);
	import alu_pkg::*;

//------------------------------------------------------------------------------
// function: get_input - generate random input data for the tester
//------------------------------------------------------------------------------

	function single_op_input_t get_input();
		single_op_input_t ret_data;
		// only valid nr of args
		ret_data.arg_number = arg_num_t'($urandom_range(10,2));
		ret_data.data_parity = parity_correct;
		ret_data.cmd_parity = parity_correct;
		case ($urandom_range(3, 0))
			0: ret_data.data_val = all_zeros;
			1: ret_data.data_val = all_ones;
			default: ret_data.data_val = random;
		endcase
		
		ret_data.cmd = get_cmd();
		
		for(int i = 0; i < ret_data.arg_number; i++) begin
			ret_data.data[(i*8)+:8] = get_data(ret_data.data_val);
		end
		
		return ret_data;
	endfunction : get_input

	function command_t get_cmd();
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
	
	function bit [7:0] get_data(data_value_t dat_val);
		bit [7:0] data;
	    bit [1:0] zero_ones;
		case(dat_val)
			random: begin
			    zero_ones = 2'($random);
			    if (zero_ones == 2'b00)
			        data = 8'h00;
			    else if (zero_ones == 2'b11)
			        data = 8'hFF;
			    else
			        data =  8'($random);
			end
			all_zeros: data = 8'h00;
			all_ones: data = 8'hFF;
		endcase
	    return data;
	endfunction
	
	initial begin
		single_op_input_t sin_op_in;
	
	    bfm.reset_alu();
	    repeat (1000) begin : random_loop
		    sin_op_in = get_input();
		    bfm.send_op(sin_op_in);
	    end : random_loop
	end // initial begin
endmodule : alu_tester_module
