
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[9:0] {
	cmd_and = 10'b1000000010,
	cmd_add = 10'b1000100000,
	cmd_inv = 10'b1100000000
} command_t;

typedef enum bit[9:0] {
	sts_noerr =  10'b1000000001,
    sts_invcmd = 10'b1100000000
} status_t;

bit				   din;
bit                clk;
bit                rst_n;
bit                enable_n;

wire               dout;
wire        	   dout_valid;

command_t          input_cmd;
bit [9:0]		   input_data_1, input_data_2;
bit	[9:0] 		   output_status, output_data_1, output_data_2;
	
bit [29:0]		   expected_result;
string             test_result = "PASSED";

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
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

function command_t get_cmd();
	bit cmd_choice;
	cmd_choice = $random;
	case (cmd_choice)
		1'b00 : return cmd_and;
		1'b01 : return cmd_add;
		default : return cmd_inv;
	endcase
endfunction : get_cmd

//---------------------------------

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

//------------------------
// Tester main
//------------------------

initial begin : tester
    reset_alu();
	repeat (100) begin : tester_main
		@(negedge clk);		
		input_data_1 = get_data();
		input_data_2 = get_data();
		input_cmd = get_cmd();
		
		enable_n = 1'b0;	
		send_word(input_data_1);
		send_word(input_data_2);
		send_word(input_cmd);
		enable_n = 1'b1;
		
		wait(dout_valid);
		receive_word(output_status);
		receive_word(output_data_1);
		receive_word(output_data_2);
		
		expected_result = get_expected(input_data_1, input_data_2, input_cmd);
		
		assert(expected_result == {output_status, output_data_1, output_data_2}) begin
			test_result = test_result;
		end
		else begin
			test_result = "FAILED";
		end
	end : tester_main
	$finish;
end : tester

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
		cmd_add : begin
			status = sts_noerr;
			result = in1[8:1] + in2[8:1];
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
// Temporary. The scoreboard data will be later used.
final begin : finish_of_the_test
    $display("Test %s.",test_result);
end
//------------------------------------------------------------------------------
endmodule : top

