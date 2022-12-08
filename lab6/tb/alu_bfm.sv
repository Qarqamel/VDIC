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
//bit [29:0]			expected_result;

//modport tlm (import reset_alu, send_word, receive_word);

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

	@(negedge clk);
	
	output_rcvd_flag = 0;
	single_op_input = op;

	case(single_op_input.cmd)
		cmd_rst: begin
			reset_alu();
		end
		cmd_nop: begin	
			for(int i = 0; i < single_op_input.arg_number; i++) begin
				send_word(single_op_input.data[(i*10)+:10]);	
			end
			send_word(single_op_input.cmd);
		end
		default: begin	
			for(int i = 0; i < single_op_input.arg_number; i++) begin
				send_word(single_op_input.data[(i*10)+:10]);	
			end
			send_word(single_op_input.cmd);
			
			receive_word(output_status);
			receive_word(output_data[19:10]);
			receive_word(output_data[9:0]);
			
			output_rcvd_flag = 1;
			
		end
	endcase

endtask

//------------------------------------------------------------------------------
// write operation monitor
//------------------------------------------------------------------------------

always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
    single_op_input_t op_in;
    if (!enable_n) begin : start_high
        if (!in_command) begin : new_command
	        op_in = single_op_input;
            operation_monitor_h.write_to_monitor(op_in);
            in_command = 1;
        end : new_command
    end : start_high
    else // start low
        in_command = 0;
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    single_op_input_t op_in;
    op_in.cmd = cmd_rst;
    if (operation_monitor_h != null) //guard against VCS time 0 negedge
        operation_monitor_h.write_to_monitor(op_in);
end : rst_monitor

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (output_rcvd_flag)
            result_monitor_h.write_to_monitor({output_status, output_data});
    end
end : result_monitor_thread

endinterface : alu_bfm
