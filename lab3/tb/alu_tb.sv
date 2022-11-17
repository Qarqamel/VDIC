
module top;

//------------------------------------------------------------------------------
// type definitions
//------------------------------------------------------------------------------

typedef enum bit[9:0] {
	cmd_nop = 10'b1000000001,
	cmd_and = 10'b1000000010,
	cmd_or =  10'b1000000100,
	cmd_xor = 10'b1000000111,
	cmd_add = 10'b1000100000,
	cmd_sub = 10'b1001000000,
	cmd_inv = 10'b1100000000,
	cmd_rst = 10'b1111111111
} command_t;

typedef enum int {
	arg_num_0 = 0,
	arg_num_1 = 1,
	arg_num_2 = 2,
	arg_num_3 = 3,
	arg_num_4 = 4,
	arg_num_5 = 5,
	arg_num_6 = 6,
	arg_num_7 = 7,
	arg_num_8 = 8,
	arg_num_9 = 9,
	arg_num_10 = 10
} arg_num_t;

typedef enum logic {
	parity_wrong = 0,
	parity_correct = 1
} parity_t;

typedef enum {
	all_ones,
	all_zeros,
	random
} data_value_t;

 typedef struct {
	command_t			cmd;
	bit [99:0]			data;
	arg_num_t			arg_number;
	parity_t			parity;
	data_value_t		data_val;
} single_op_input_t;

typedef enum bit[9:0] {
	sts_noerr =  10'b1000000001,
	sts_invcmd = 10'b1100000000
} status_t;

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;



//------------------------------------------------------------------------------
// variable definitions
//------------------------------------------------------------------------------

bit                din;
bit                clk;
bit                rst_n;
bit                enable_n;

wire               dout;
wire        	   dout_valid;

single_op_input_t	single_op_input;

bit [9:0]			output_status;
bit [19:0]			output_data;

bit					output_rcvd_flag;
bit [29:0]			expected_result;
test_result_t		test_result = TEST_PASSED;
	
//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2022 u_vdic_dut_2022 (
	.clk       (clk),
	.din       (din),
	.dout      (dout),
	.dout_valid(dout_valid),
	.enable_n  (enable_n),
	.rst_n     (rst_n)
);

//------------------------------------------------------------------------------
// Coverage groups
//------------------------------------------------------------------------------

covergroup cmd_cov;
	
	option.name = "cg_cmd_cov";
	
	coverpoint single_op_input.cmd{
		
		bins A1_single[] = {[cmd_nop:cmd_sub], cmd_rst, cmd_inv};
		bins A2_rst_cmd[] = (cmd_rst => [cmd_nop:cmd_inv]);
		bins A3_cmd_rst[] = ([cmd_nop:cmd_inv] => cmd_rst);
		bins A4_dbl_cmd[] = ([cmd_nop:cmd_inv] [* 2]);
	}
endgroup

covergroup min_max_arg;
	
	option.name = "cg_min_max_arg";
	
	all_cmd : coverpoint single_op_input.cmd{
		ignore_bins null_ops = {cmd_nop, cmd_rst, cmd_inv};
	}
	
	data_zeros_ones :  coverpoint single_op_input.data_val{
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

	all_cmd : coverpoint single_op_input.cmd{
		ignore_bins null_ops = {cmd_rst};
	}
	
	data_nr_of_args : coverpoint single_op_input.arg_number{
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
        @(negedge clk);
        if(!enable_n || !rst_n) begin
	        #1
            cc.sample();
            mma.sample();
	        noa.sample();
        end
    end
end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen
    clk = 0;
    forever begin : clk_frv
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// Tester main
//------------------------------------------------------------------------------

initial begin : tester
    reset_alu();
	repeat (1000) begin : tester_main
		@(negedge clk);
		output_rcvd_flag = 0;
		single_op_input = get_random_input();
				
		case(single_op_input.cmd)
			cmd_rst: begin
				reset_alu();
			end
			cmd_nop: begin
				enable_n = 1'b0;	
				for(int i = 0; i < single_op_input.arg_number; i++) begin
					send_word(single_op_input.data[(i*10)+:10]);	
				end
				send_word(single_op_input.cmd);
				enable_n = 1'b1;
			end
			default: begin
				enable_n = 1'b0;	
				for(int i = 0; i < single_op_input.arg_number; i++) begin
					send_word(single_op_input.data[(i*10)+:10]);	
				end
				send_word(single_op_input.cmd);
				enable_n = 1'b1;
				
				wait(dout_valid);
				receive_word(output_status);
				receive_word(output_data[19:10]);
				receive_word(output_data[9:0]);
				
				output_rcvd_flag = 1;
				
				expected_result = get_expected(single_op_input);
		
				assert(expected_result == {output_status, output_data}) begin
					test_result = test_result;
				end
				else begin
					test_result = TEST_FAILED;
				end
			end
		endcase		
	end : tester_main
	$finish;
end : tester

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
// reset task
//------------------------------------------------------------------------------
task reset_alu();
    //`ifdef DEBUG
    //$display("%0t DEBUG: reset_alu", $time);
    //`endif
    enable_n   = 1'b1;
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask

//------------------------------------------------------------------------------
// send word task
//------------------------------------------------------------------------------

task send_word(
		bit [0:9] input_word
	);
	int i;
	for (i = 0; i < 10; i++) begin
		din = input_word[i];
		@(negedge clk);
	end
endtask

//------------------------------------------------------------------------------
// receive word task
//------------------------------------------------------------------------------

task receive_word(output [0:9] word);
	bit [0:9] rcvd_word;
	int i;
	for (i = 0; i < 10; i++) begin
		@(negedge clk);
		rcvd_word[i] = dout;		
	end
	word = rcvd_word;
endtask

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function logic [29:0] get_expected(single_op_input_t single_input);
	bit [15:0] result;
	bit [9:0] status;
	bit [29:0] ret_val;
	result = 16'h00FF & single_input.data[8:1];
	for (int i = 1; i < single_input.arg_number; i++) begin
		case(single_input.cmd)
			cmd_and : begin
				status = sts_noerr;
				result = result & single_input.data[((i*10)+1)+:8];
			end
			cmd_or : begin
				status = sts_noerr;
				result = result | single_input.data[((i*10)+1)+:8];
			end
			cmd_xor : begin
				status = sts_noerr;
				result = result ^ single_input.data[((i*10)+1)+:8];
			end
			cmd_add : begin
				status = sts_noerr;
				result = result + single_input.data[((i*10)+1)+:8];
			end
			cmd_sub : begin
				status = sts_noerr;
				result = result - single_input.data[((i*10)+1)+:8];

			end
			default: begin
				status = sts_invcmd;
				result = 0;
			end
		endcase
	end
	ret_val[29:20] = status;
	ret_val[19] = 1'b0;
	ret_val[18:11] = result[15:8];
	ret_val[10] = ^ret_val[19:11];
	ret_val[9] = 1'b0;
	ret_val[8:1] = result[7:0];
	ret_val[0] = ^ret_val[9:1];
	return(ret_val);
endfunction

//------------------------------------------------------------------------------
// modify the color of the text printed on the terminal
//------------------------------------------------------------------------------

function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

//------------------------------------------------------------------------------
// display test result
//------------------------------------------------------------------------------

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction

//------------------------------------------------------------------------------
// Temporary. The scoreboard data will be later used.
final begin : finish_of_the_test
    print_test_result(test_result);
end
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
always @(negedge clk) begin : scoreboard
    if(output_rcvd_flag) begin:verify_result
        bit [29:0] predicted_result;

        predicted_result = get_expected(single_op_input);

        CHK_RESULT: assert({output_status, output_data} === predicted_result) begin
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, A, B, op);
           `endif
        end
        else begin
            $error("%0t Test FAILED for in=%0d cmd=%0d\nExpected: %d  received: %d",
                $time, single_op_input.data, single_op_input.cmd , predicted_result, {output_status, output_data});
        end;
    end
end : scoreboard

endmodule : top

