
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
		
	task execute();
		forever begin
			@(negedge bfm.clk) 
		    if(bfm.output_rcvd_flag) begin:verify_result
		        bit [29:0] predicted_result;
		
		        predicted_result = get_expected(bfm.single_op_input);
		
		        CHK_RESULT: assert({bfm.output_status, bfm.output_data} === predicted_result) begin
		           `ifdef DEBUG
		            $display("%0t Test passed for A=%0d B=%0d op_set=%0d", 
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



//module scoreboard(alu_bfm bfm);
//	
//import alu_pkg::*;
//	
////------------------------------------------------------------------------------
//// type definitions
////------------------------------------------------------------------------------
//
//typedef enum bit {
//    TEST_PASSED,
//    TEST_FAILED
//} test_result_t;
//
//typedef enum {
//    COLOR_BOLD_BLACK_ON_GREEN,
//    COLOR_BOLD_BLACK_ON_RED,
//    COLOR_BOLD_BLACK_ON_YELLOW,
//    COLOR_BOLD_BLUE_ON_WHITE,
//    COLOR_BLUE_ON_WHITE,
//    COLOR_DEFAULT
//} print_color_t;
//	
////------------------------------------------------------------------------------
//// local variables
////------------------------------------------------------------------------------
//
//test_result_t test_result = TEST_PASSED;
//	
////------------------------------------------------------------------------------
//// calculate expected result
////------------------------------------------------------------------------------
//
//function logic [29:0] get_expected(single_op_input_t single_input);
//	bit [15:0] result;
//	bit [9:0] status;
//	bit [29:0] ret_val;
//	result = 16'h00FF & single_input.data[8:1];
//	for (int i = 1; i < single_input.arg_number; i++) begin
//		case(single_input.cmd)
//			cmd_and : begin
//				status = sts_noerr;
//				result = result & single_input.data[((i*10)+1)+:8];
//			end
//			cmd_or : begin
//				status = sts_noerr;
//				result = result | single_input.data[((i*10)+1)+:8];
//			end
//			cmd_xor : begin
//				status = sts_noerr;
//				result = result ^ single_input.data[((i*10)+1)+:8];
//			end
//			cmd_add : begin
//				status = sts_noerr;
//				result = result + single_input.data[((i*10)+1)+:8];
//			end
//			cmd_sub : begin
//				status = sts_noerr;
//				result = result - single_input.data[((i*10)+1)+:8];
//
//			end
//			default: begin
//				status = sts_invcmd;
//				result = 0;
//			end
//		endcase
//	end
//	ret_val[29:20] = status;
//	ret_val[19] = 1'b0;
//	ret_val[18:11] = result[15:8];
//	ret_val[10] = ^ret_val[19:11];
//	ret_val[9] = 1'b0;
//	ret_val[8:1] = result[7:0];
//	ret_val[0] = ^ret_val[9:1];
//	return(ret_val);
//endfunction
//
////------------------------------------------------------------------------------
//// modify the color of the text printed on the terminal
////------------------------------------------------------------------------------
//
//function void set_print_color ( print_color_t c );
//    string ctl;
//    case(c)
//        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
//        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
//        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
//        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
//        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
//        COLOR_DEFAULT : ctl              = "\033\[0m\n";
//        default : begin
//            $error("set_print_color: bad argument");
//            ctl                          = "";
//        end
//    endcase
//    $write(ctl);
//endfunction
//
////------------------------------------------------------------------------------
//// display test result
////------------------------------------------------------------------------------
//
//function void print_test_result (test_result_t r);
//    if(r == TEST_PASSED) begin
//        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
//        $write ("-----------------------------------\n");
//        $write ("----------- Test PASSED -----------\n");
//        $write ("-----------------------------------");
//        set_print_color(COLOR_DEFAULT);
//        $write ("\n");
//    end
//    else begin
//        set_print_color(COLOR_BOLD_BLACK_ON_RED);
//        $write ("-----------------------------------\n");
//        $write ("----------- Test FAILED -----------\n");
//        $write ("-----------------------------------");
//        set_print_color(COLOR_DEFAULT);
//        $write ("\n");
//    end
//endfunction
//
////------------------------------------------------------------------------------
//// Scoreboard
////------------------------------------------------------------------------------
//
//always @(negedge bfm.clk) begin : scoreboard
//    if(bfm.output_rcvd_flag) begin:verify_result
//        bit [29:0] predicted_result;
//
//        predicted_result = get_expected(bfm.single_op_input);
//
//        CHK_RESULT: assert({bfm.output_status, bfm.output_data} === predicted_result) begin
//           `ifdef DEBUG
//            $display("%0t Test passed for A=%0d B=%0d op_set=%0d", 
//	            $time, bfm.single_op_input.data, bfm.single_op_input.cmd);
//           `endif
//        end
//        else begin
//            $error("%0t Test FAILED for in=%0d cmd=%0d\nExpected: %d  received: %d",
//                $time, bfm.single_op_input.data, bfm.single_op_input.cmd , predicted_result, {bfm.output_status, bfm.output_data});
//        	test_result = TEST_FAILED;
//        end;
//    end
//end : scoreboard
//
////------------------------------------------------------------------------------
//// print the test result at the simulation end
////------------------------------------------------------------------------------
//
//final begin : finish_of_the_test
//    print_test_result(test_result);
//end
//
//endmodule
