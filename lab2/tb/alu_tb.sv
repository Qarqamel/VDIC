
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
	//cmd_inv = 10'b1100000000,
	cmd_rst = 10'b1111111111
} command_t;

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

bit				   din;
bit                clk;
bit                rst_n;
bit                enable_n;

wire               dout;
wire        	   dout_valid;

command_t          input_cmd;
bit [9:0]		   input_data_1, input_data_2;
bit	[9:0] 		   output_status, output_data_1, output_data_2;
bit				   output_rcvd_flag;
	
bit [29:0]		   expected_result;
test_result_t      test_result = TEST_PASSED;

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
	
	coverpoint input_cmd{
		
		bins A1_single[] = {[cmd_nop:cmd_sub], cmd_rst};
		bins A2_rst_cmd[] = (cmd_rst => [cmd_nop:cmd_sub]);
		bins A3_cmd_rst[] = ([cmd_nop:cmd_sub] => cmd_rst);
		bins A4_dbl_cmd[] = ([cmd_nop:cmd_sub] [* 2]);
	}
endgroup

covergroup min_max_arg;
	
	option.name = "cg_min_max_arg";
	
	all_cmd : coverpoint input_cmd{
		ignore_bins null_ops = {cmd_nop, cmd_rst};
	}
	
	a_val : coverpoint input_data_1 {
        bins zeros = {'h00};
        bins others= {['h03:'h1FD]};
        bins ones  = {'h1FE};
	}
	
	b_val : coverpoint input_data_2 {
        bins zeros = {'h00};
        bins others= {['h03:'h1FD]};
        bins ones  = {'h1FE};
	}
	
	B_cmd_min_max : cross a_val, b_val, all_cmd {
		bins B0_and_00 = binsof (all_cmd) intersect {cmd_and} && (binsof (a_val.zeros) || binsof (b_val.zeros));
		bins B0_or_00 =  binsof (all_cmd) intersect {cmd_or} && (binsof (a_val.zeros) || binsof (b_val.zeros));
		bins B0_xor_00 = binsof (all_cmd) intersect {cmd_xor} && (binsof (a_val.zeros) || binsof (b_val.zeros));
		bins B0_add_00 = binsof (all_cmd) intersect {cmd_add} && (binsof (a_val.zeros) || binsof (b_val.zeros));
		bins B0_sub_00 = binsof (all_cmd) intersect {cmd_sub} && (binsof (a_val.zeros) || binsof (b_val.zeros));
		
		bins B1_and_11 = binsof (all_cmd) intersect {cmd_and} && (binsof (a_val.ones) || binsof (b_val.ones));
		bins B1_or_11 =  binsof (all_cmd) intersect {cmd_or} && (binsof (a_val.ones) || binsof (b_val.ones));
		bins B1_xor_11 = binsof (all_cmd) intersect {cmd_xor} && (binsof (a_val.ones) || binsof (b_val.ones));
		bins B1_add_11 = binsof (all_cmd) intersect {cmd_add} && (binsof (a_val.ones) || binsof (b_val.ones));
		bins B1_sub_11 = binsof (all_cmd) intersect {cmd_sub} && (binsof (a_val.ones) || binsof (b_val.ones));
		
		ignore_bins others_only = binsof(a_val.others) && binsof(b_val.others);
	}
endgroup

cmd_cov cc;
min_max_arg mma;

initial begin : coverage
    cc  = new();
    mma = new();
    forever begin : sample_cov
        @(negedge clk);
        if(!enable_n || !rst_n) begin
            cc.sample();
            mma.sample();
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
	repeat (100) begin : tester_main
		@(negedge clk);
		output_rcvd_flag = 0;
		input_data_1 = get_data();
		input_data_2 = get_data();
		input_cmd = get_cmd();
				
		case(input_cmd)
			cmd_rst: begin
				reset_alu();
			end
			cmd_nop: begin
				enable_n = 1'b0;	
				send_word(input_data_1);
				send_word(input_data_2);
				send_word(input_cmd);
				enable_n = 1'b1;
			end
			default: begin
				enable_n = 1'b0;	
				send_word(input_data_1);
				send_word(input_data_2);
				send_word(input_cmd);
				enable_n = 1'b1;
				
				wait(dout_valid);
				receive_word(output_status);
				receive_word(output_data_1);
				receive_word(output_data_2);
				
				output_rcvd_flag = 1;
				
				expected_result = get_expected(input_data_1, input_data_2, input_cmd);
		
				assert(expected_result == {output_status, output_data_1, output_data_2}) begin
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
		3'b110 : return cmd_rst;
		3'b111 : return cmd_rst;
	endcase
endfunction : get_cmd

function bit [9:0] get_data();
	bit [9:0] data;
    bit [1:0] zero_ones;
	data[9] = 0;
    zero_ones = 2'($random);
    if (zero_ones == 2'b00)
        data[8:1] = 8'h00;
    else if (zero_ones == 2'b11)
        data[8:1] = 8'hFF;
    else
        data[8:1] =  8'($random);
    data[0] = ^data[9:1];
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

function logic [29:0] get_expected(
		bit [9:0] in1,
		bit [9:0] in2,
		command_t cmd
	);
	bit [15:0] result;
	bit [9:0] status;
	bit [29:0] ret_val;
	case(cmd)
		cmd_and : begin
			status = sts_noerr;
			result = in1[8:1] & in2[8:1];
		end
		cmd_or : begin
			status = sts_noerr;
			result = in1[8:1] | in2[8:1];
		end
		cmd_xor : begin
			status = sts_noerr;
			result = in1[8:1] ^ in2[8:1];
		end
		cmd_add : begin
			status = sts_noerr;
			result = in1[8:1] + in2[8:1];
		end
		cmd_sub : begin
			status = sts_noerr;
			result = in1[8:1] - in2[8:1];
		end
		default: begin
			status = sts_invcmd;
			result = 0;
		end
	endcase
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

        predicted_result = get_expected(input_data_1, input_data_2, input_cmd);

        CHK_RESULT: assert({output_status, output_data_1, output_data_2} === predicted_result) begin
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d op_set=%0d", $time, A, B, op);
           `endif
        end
        else begin
            $error("%0t Test FAILED for in1=%0d in2=%0d cmd=%0d\nExpected: %d  received: %d",
                $time, input_data_1, input_data_2, input_cmd , predicted_result, {output_status, output_data_1, output_data_2});
        end;
    end
end : scoreboard

endmodule : top

