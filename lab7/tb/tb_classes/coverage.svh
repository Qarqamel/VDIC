
class coverage extends uvm_subscriber #(operation_transaction);
	`uvm_component_utils(coverage)
//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------
	
	protected single_op_input_t sin_op;
	
//------------------------------------------------------------------------------
// Coverage groups
//------------------------------------------------------------------------------
	
	covergroup cmd_cov;
	
		option.name = "cg_cmd_cov";
		
		coverpoint sin_op.cmd{
			
			bins A1_single[] = {[cmd_nop:cmd_sub], cmd_rst, cmd_inv};
			bins A2_rst_cmd[] = (cmd_rst => [cmd_nop:cmd_inv]);
			bins A3_cmd_rst[] = ([cmd_nop:cmd_inv] => cmd_rst);
			bins A4_dbl_cmd[] = ([cmd_nop:cmd_inv] [* 2]);
		}
	endgroup
	
	covergroup min_max_arg;
		
		option.name = "cg_min_max_arg";
		
		all_cmd : coverpoint sin_op.cmd{
			ignore_bins null_ops = {cmd_nop, cmd_rst, cmd_inv};
		}
		
		data_zeros_ones :  coverpoint sin_op.data{
			bins zeros = {80'h0};
			bins ones = {80'hFFFFFFFFFFFFFFFFFFFF};
			bins others = {[80'h1 : 80'hFFFFFFFFFFFFFFFFFFFE]};
		}
			
		B_cmd_min_max : cross data_zeros_ones, all_cmd {
			bins B0_and_00 = binsof (all_cmd) intersect {cmd_and} && (binsof (data_zeros_ones.zeros));
			bins B0_or_00 =  binsof (all_cmd) intersect {cmd_or} && (binsof (data_zeros_ones.zeros));
			bins B0_xor_00 = binsof (all_cmd) intersect {cmd_xor} && (binsof (data_zeros_ones.zeros));
			bins B0_add_00 = binsof (all_cmd) intersect {cmd_add} && (binsof (data_zeros_ones.zeros));
			bins B0_sub_00 = binsof (all_cmd) intersect {cmd_sub} && (binsof (data_zeros_ones.zeros));
			
			bins B1_and_FF = binsof (all_cmd) intersect {cmd_and} && (binsof (data_zeros_ones.ones));
			bins B1_or_FF =  binsof (all_cmd) intersect {cmd_or} && (binsof (data_zeros_ones.ones));
			bins B1_xor_FF = binsof (all_cmd) intersect {cmd_xor} && (binsof (data_zeros_ones.ones));
			bins B1_add_FF = binsof (all_cmd) intersect {cmd_add} && (binsof (data_zeros_ones.ones));
			bins B1_sub_FF = binsof (all_cmd) intersect {cmd_sub} && (binsof (data_zeros_ones.ones));
					
			ignore_bins others_only = binsof(data_zeros_ones.others);
		}
	endgroup
	
	covergroup nr_of_args;
		
		option.name = "cg_nr_of_args";
	
		all_cmd : coverpoint sin_op.cmd{
			ignore_bins null_ops = {cmd_rst};
		}
		
		data_nr_of_args : coverpoint sin_op.arg_number{
			bins valid = {[2:10]};
			ignore_bins low_invalid = {[0:1]};
			ignore_bins high_invalid = {11};
		}
		
		C_cmd_nr_args : cross data_nr_of_args, all_cmd{
			
			bins C0_nop_valid = binsof (all_cmd) intersect {cmd_nop} && (binsof (data_nr_of_args.valid));
			bins C0_and_valid = binsof (all_cmd) intersect {cmd_and} && (binsof (data_nr_of_args.valid));
			bins C0_or_valid = binsof (all_cmd) intersect {cmd_or} && (binsof (data_nr_of_args.valid));
			bins C0_xor_valid = binsof (all_cmd) intersect {cmd_xor} && (binsof (data_nr_of_args.valid));
			bins C0_add_valid = binsof (all_cmd) intersect {cmd_add} && (binsof (data_nr_of_args.valid));
			bins C0_sub_valid = binsof (all_cmd) intersect {cmd_sub} && (binsof (data_nr_of_args.valid));		
			bins C0_inv_valid = binsof (all_cmd) intersect {cmd_inv} && (binsof (data_nr_of_args.valid));
			
			//for now
			ignore_bins invalid_nr_low = binsof(data_nr_of_args.low_invalid);
			ignore_bins invalid_nr_high = binsof(data_nr_of_args.high_invalid);
		}
	endgroup
	
	covergroup data_parity;
		
		option.name = "cg_data_parity";
	
		all_cmd : coverpoint sin_op.cmd{
			ignore_bins null_ops = {cmd_rst};
		}
		
		data_parity : coverpoint sin_op.data_parity{
			bins correct = parity_correct;
			bins wrong = parity_wrong;
		}
		
		D_cmd_data_parity : cross data_parity, all_cmd{
			
			bins D0_nop_correct = binsof (all_cmd) intersect {cmd_nop} && (binsof (data_parity.correct));
			bins D0_and_correct = binsof (all_cmd) intersect {cmd_and} && (binsof (data_parity.correct));
			bins D0_or_correct = binsof (all_cmd) intersect {cmd_or} && (binsof (data_parity.correct));
			bins D0_xor_correct = binsof (all_cmd) intersect {cmd_xor} && (binsof (data_parity.correct));
			bins D0_add_correct = binsof (all_cmd) intersect {cmd_add} && (binsof (data_parity.correct));
			bins D0_sub_correct = binsof (all_cmd) intersect {cmd_sub} && (binsof (data_parity.correct));		
			bins D0_inv_correct = binsof (all_cmd) intersect {cmd_inv} && (binsof (data_parity.correct));
			
			bins D1_nop_wrong = binsof (all_cmd) intersect {cmd_nop} && (binsof (data_parity.wrong));
			bins D1_and_wrong = binsof (all_cmd) intersect {cmd_and} && (binsof (data_parity.wrong));
			bins D1_or_wrong = binsof (all_cmd) intersect {cmd_or} && (binsof (data_parity.wrong));
			bins D1_xor_wrong = binsof (all_cmd) intersect {cmd_xor} && (binsof (data_parity.wrong));
			bins D1_add_wrong = binsof (all_cmd) intersect {cmd_add} && (binsof (data_parity.wrong));
			bins D1_sub_wrong = binsof (all_cmd) intersect {cmd_sub} && (binsof (data_parity.wrong));		
			bins D1_inv_wrong = binsof (all_cmd) intersect {cmd_inv} && (binsof (data_parity.wrong));
		}
	endgroup
	
	covergroup command_parity;
		
		option.name = "cg_command_parity";
	
		all_cmd : coverpoint sin_op.cmd{
			ignore_bins null_ops = {cmd_rst};
		}
		
		command_parity : coverpoint sin_op.cmd_parity{
			bins correct = parity_correct;
			bins wrong = parity_wrong;
		}
		
		D_cmd_command_parity : cross command_parity, all_cmd{
			
			bins E0_nop_correct = binsof (all_cmd) intersect {cmd_nop} && (binsof (command_parity.correct));
			bins E0_and_correct = binsof (all_cmd) intersect {cmd_and} && (binsof (command_parity.correct));
			bins E0_or_correct = binsof (all_cmd) intersect {cmd_or} && (binsof (command_parity.correct));
			bins E0_xor_correct = binsof (all_cmd) intersect {cmd_xor} && (binsof (command_parity.correct));
			bins E0_add_correct = binsof (all_cmd) intersect {cmd_add} && (binsof (command_parity.correct));
			bins E0_sub_correct = binsof (all_cmd) intersect {cmd_sub} && (binsof (command_parity.correct));		
			bins E0_inv_correct = binsof (all_cmd) intersect {cmd_inv} && (binsof (command_parity.correct));
			
			bins E1_nop_wrong = binsof (all_cmd) intersect {cmd_nop} && (binsof (command_parity.wrong));
			bins E1_and_wrong = binsof (all_cmd) intersect {cmd_and} && (binsof (command_parity.wrong));
			bins E1_or_wrong = binsof (all_cmd) intersect {cmd_or} && (binsof (command_parity.wrong));
			bins E1_xor_wrong = binsof (all_cmd) intersect {cmd_xor} && (binsof (command_parity.wrong));
			bins E1_add_wrong = binsof (all_cmd) intersect {cmd_add} && (binsof (command_parity.wrong));
			bins E1_sub_wrong = binsof (all_cmd) intersect {cmd_sub} && (binsof (command_parity.wrong));		
			bins E1_inv_wrong = binsof (all_cmd) intersect {cmd_inv} && (binsof (command_parity.wrong));
		}
	endgroup

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
		super.new(name, parent);
		cmd_cov = new();
		min_max_arg = new();
		nr_of_args = new();
		data_parity = new();
		command_parity = new();
	endfunction

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(operation_transaction t);
        sin_op = t.sin_op_in;
        cmd_cov.sample();
        min_max_arg.sample();
        nr_of_args.sample();
        data_parity.sample();
	    command_parity.sample();
    endfunction : write
	
endclass
