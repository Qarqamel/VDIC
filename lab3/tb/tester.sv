
module tester(alu_bfm bfm);
	
import alu_pkg::*;
	
//------------------------------------------------------------------------------
// Random data generation functions
//------------------------------------------------------------------------------

function single_op_input_t get_random_input();
	single_op_input_t ret_data;
	// for now only use correct parity input data
	ret_data.parity = parity_correct;
	// only valid nr of args
	ret_data.arg_number = arg_num_t'($urandom_range(9,2));

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
endfunction : get_random_input

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

function bit [9:0] get_data(data_value_t dat_val, parity_t par);
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

//------------------------------------------------------------------------------
// Tester main
//------------------------------------------------------------------------------

initial begin : tester	
    bfm.reset_alu();
	repeat (1000) begin : tester_main
		
		//@(negedge clk);
		
		bfm.output_rcvd_flag = 0;
		bfm.single_op_input = get_random_input();
	
		case(bfm.single_op_input.cmd)
			cmd_rst: begin
				bfm.reset_alu();
			end
			cmd_nop: begin	
				for(int i = 0; i < bfm.single_op_input.arg_number; i++) begin
					bfm.send_word(bfm.single_op_input.data[(i*10)+:10]);	
				end
				bfm.send_word(bfm.single_op_input.cmd);
			end
			default: begin	
				for(int i = 0; i < bfm.single_op_input.arg_number; i++) begin
					bfm.send_word(bfm.single_op_input.data[(i*10)+:10]);	
				end
				bfm.send_word(bfm.single_op_input.cmd);
				
				bfm.receive_word(bfm.output_status);
				bfm.receive_word(bfm.output_data[19:10]);
				bfm.receive_word(bfm.output_data[9:0]);
				
				bfm.output_rcvd_flag = 1;
				
			end
		endcase		
	end : tester_main
	$finish;
end : tester
	
endmodule
