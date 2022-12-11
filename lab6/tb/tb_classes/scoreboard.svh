
class scoreboard extends uvm_subscriber #(result_t);
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

	uvm_tlm_analysis_fifo #(single_op_input_t) op_in;
	
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
	
	protected function bit [29:0] get_expected(single_op_input_t single_input);
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
        op_in = new ("op_in", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(result_t t);
	    	    
        result_t predicted_result;	    
        single_op_input_t op;

        do
            if (!op_in.try_get(op))
                $fatal(1, "Missing command in self checker");
        while ((op.cmd == cmd_nop) || (op.cmd == cmd_rst));

        predicted_result.data = get_expected(op);

        SCOREBOARD_CHECK:
        assert (predicted_result.data == t.data) begin
           `ifdef DEBUG
            $display("%0t Test passed for Data=%0d op_set=%0d", $time, op.data, op.cmd);
            `endif
        end
        else begin
            $error ("FAILED: Data: %0h, op: %s, arg_nr: %s, parity: %s, result: %0h", op.data, op.cmd.name(), op.arg_number.name(), op.parity.name(), t.data);
            tr = TEST_FAILED;
        end
    endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass

