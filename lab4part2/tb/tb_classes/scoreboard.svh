
class scoreboard;

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

	virtual alu_bfm bfm;
	
	function new (virtual alu_bfm b);
		bfm = b;
	endfunction
	
//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
	
	protected function logic [29:0] get_expected(single_op_input_t single_input);
		bit [15:0] result;
		bit [9:0] status;
		bit [29:0] ret_val;
		result = 16'h00FF & single_input.data[8:1];
		for (int i = 1; i < single_input.arg_number; i++) begin
//			if (single_input.cmd == cmd_inv)begin
//				status |= sts_invcmd;
//				result = 0;
//			end
			case(single_input.cmd)
				cmd_and : begin
					status |= sts_noerr;
					result = result & single_input.data[((i*10)+1)+:8];
				end
				cmd_or : begin
					status |= sts_noerr;
					result = result | single_input.data[((i*10)+1)+:8];
				end
				cmd_xor : begin
					status |= sts_noerr;
					result = result ^ single_input.data[((i*10)+1)+:8];
				end
				cmd_add : begin
					status |= sts_noerr;
					result = result + single_input.data[((i*10)+1)+:8];
				end
				cmd_sub : begin
					status |= sts_noerr;
					result = result - single_input.data[((i*10)+1)+:8];
	
				end
				default: begin
					status |= sts_invcmd;
					result = 0;
				end
			endcase
			if (single_input.parity == parity_wrong) begin
				status |= sts_parerr;
				result = 0;	
			end
		end
		ret_val[29:21] = status;
		ret_val[20] = ^ret_val[29:21];
		ret_val[19] = 1'b0;
		ret_val[18:11] = result[15:8];
		ret_val[10] = ^ret_val[19:11];
		ret_val[9] = 1'b0;
		ret_val[8:1] = result[7:0];
		ret_val[0] = ^ret_val[9:1];
		return(ret_val);
	endfunction
		
	task execute();
		forever begin
			@(negedge bfm.clk) 
		    if(bfm.output_rcvd_flag) begin:verify_result
		        bit [29:0] predicted_result;
		
		        predicted_result = get_expected(bfm.single_op_input);

		        CHK_RESULT: assert({bfm.output_status, bfm.output_data} === predicted_result) begin
		           `ifdef DEBUG
		            $display("%0t Test passed for Data=%0d op_set=%0d", 
			            $time, bfm.single_op_input.data, bfm.single_op_input.cmd);
		           `endif
		        end
		        else begin
		            $error("%0t Test FAILED for in=%0d cmd=%0d\nExpected: %d  received: %d",
		                $time, bfm.single_op_input.data, bfm.single_op_input.cmd , predicted_result, {bfm.output_status, bfm.output_data});
		        end
		    end
		end
		
	endtask
	
endclass

