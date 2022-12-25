import alu_pkg::*;

interface alu_bfm;


bit                din;
bit                clk;
bit                rst_n;
bit                enable_n;

wire               dout;
wire        	   dout_valid;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

single_op_input_t	single_op_input;

bit [9:0]			output_status;
bit [19:0]			output_data;

bit					output_rcvd_flag;

operation_monitor operation_monitor_h;
result_monitor result_monitor_h;

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

//------------------------------------------------------------------------------
// send all operation data and read output
//------------------------------------------------------------------------------

task send_op(input single_op_input_t op);
	bit parity_bit;
	//$display("%0t Writing to monitor Data=%0d op_set=%s", $time, op.data, op.cmd.name());
	@(negedge clk);
	
	output_rcvd_flag = 0;
	single_op_input = op;
		
	case(single_op_input.cmd)
		cmd_rst: begin
			reset_alu();
		end
		cmd_nop: begin
			for(int i = 0; i < single_op_input.arg_number; i++) begin
				case(op.data_parity)
					parity_correct: parity_bit = ^single_op_input.data[(i*8)+:8];
					parity_wrong: parity_bit = ~(^single_op_input.data[(i*8)+:8]);
				endcase
				send_word({1'b0, single_op_input.data[(i*8)+:8], parity_bit});
			end
			case(op.cmd_parity)
				parity_correct: parity_bit = ^single_op_input.cmd;
				parity_wrong: parity_bit = ~(^single_op_input.cmd);
			endcase
			send_word({single_op_input.cmd, parity_bit});
			output_rcvd_flag = 1;
		end
		default: begin
			for(int i = 0; i < single_op_input.arg_number; i++) begin
				case(op.data_parity)
					parity_correct: parity_bit = ^single_op_input.data[(i*8)+:8];
					parity_wrong: parity_bit = ~(^single_op_input.data[(i*8)+:8]);
				endcase
				send_word({1'b0, single_op_input.data[(i*8)+:8], parity_bit});	
			end
			case(op.cmd_parity)
				parity_correct: parity_bit = ^single_op_input.cmd;
				parity_wrong: parity_bit = ~(^single_op_input.cmd);
			endcase
			send_word({single_op_input.cmd, parity_bit});
			
			receive_word(output_status);
			receive_word(output_data[19:10]);
			receive_word(output_data[9:0]);
			
			output_rcvd_flag = 1;
			
		end
	endcase

endtask

//------------------------------------------------------------------------------
// write operation and result monitors
//------------------------------------------------------------------------------

always @(posedge clk) begin : op_monitor
    //operation_transaction op_in;
	result_t current_result;
    if (output_rcvd_flag) begin : start_high
	    case(single_op_input.cmd)
		    cmd_rst, cmd_nop: begin
			    operation_monitor_h.write_to_monitor(single_op_input);
	    	end
	    	default: begin
		    	current_result.data = {output_status, output_data};
		        //$display("%0t Writing to monitor Data=%0d op_set=%s", $time, single_op_input.data, single_op_input.cmd.name());
		        operation_monitor_h.write_to_monitor(single_op_input);
		    	result_monitor_h.write_to_monitor(current_result);
	    	end
	    endcase
    end : start_high
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    single_op_input_t op_in;
    op_in.cmd = cmd_rst;
    if (operation_monitor_h != null) begin//guard against VCS time 0 negedge
    	//$display("%0t Writing to monitor Data=%0d op_set=%0d", $time, op_in.data, op_in.cmd);
        operation_monitor_h.write_to_monitor(op_in);
    end
end : rst_monitor

endinterface : alu_bfm
