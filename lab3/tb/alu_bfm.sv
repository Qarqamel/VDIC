
interface alu_bfm;
import alu_pkg::*;

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

modport tlm (import reset_alu, send_word, receive_word);

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

task send_word(bit [0:9] input_word);
	int i;
	@(negedge clk);
	enable_n = 1'b0;	
	for (i = 0; i < 10; i++) begin
		din = input_word[i];
		@(negedge clk);
	end
	enable_n = 1'b1;
endtask

//------------------------------------------------------------------------------
// receive word task
//------------------------------------------------------------------------------

task receive_word(output [0:9] word);
	bit [0:9] rcvd_word;
	int i;
	wait(dout_valid);
	for (i = 0; i < 10; i++) begin
		@(negedge clk);
		rcvd_word[i] = dout;		
	end
	word = rcvd_word;
endtask
	
endinterface : alu_bfm
