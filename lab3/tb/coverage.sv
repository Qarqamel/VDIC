
module coverage (alu_bfm bfm);
	
import alu_pkg::*;
	
single_op_input_t sin_op;
	
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
	
	data_zeros_ones :  coverpoint sin_op.data_val{
		bins zeros = all_zeros;
		bins ones = all_ones;
		bins others = random;
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
		bins valid = {[2:9]};
		bins invalid = {[0:1], 10};
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
		ignore_bins invalid_nr = binsof(data_nr_of_args.invalid);
	}
endgroup

cmd_cov cc;
min_max_arg mma;
nr_of_args noa;

initial begin : coverage
    cc  = new();
    mma = new();
	noa = new();
    forever begin : sample_cov
        @(negedge bfm.clk);
        if(!bfm.enable_n || !bfm.rst_n) begin
	        sin_op = bfm.single_op_input;
            cc.sample();
            mma.sample();
	        noa.sample();
	        //single_op_input = single_op_input;
        end
    end
end : coverage
	
endmodule
