
class scoreboard extends uvm_component;
	`uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// Local typedefs
//------------------------------------------------------------------------------

	typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
	} test_result;
	
//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

	protected virtual alu_bfm bfm;
	
	protected test_result tr = TEST_PASSED;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
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
// calculate expected result
//------------------------------------------------------------------------------
	
	protected function logic [29:0] get_expected(single_op_input_t single_input);
		bit [15:0] result;
		bit [8:0] status;
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
	
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

	task run_phase(uvm_phase phase);
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
		        	tr = TEST_FAILED;
		        end
		    end
		end		
	endtask

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass

