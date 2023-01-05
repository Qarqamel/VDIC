
class scoreboard extends uvm_subscriber #(result_transaction);
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

	uvm_tlm_analysis_fifo #(operation_transaction) op_in;
	
	local test_result tr = TEST_PASSED;

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
	
	local function result_transaction get_expected(operation_transaction single_input);		
		bit [15:0] result;
		bit [8:0] status;
		bit [29:0] ret_val;
		result_transaction out_res;
		
		out_res = new("out_res");
		
		result = 16'h00FF & single_input.sin_op_in.data[7:0];
		for (int i = 1; i < single_input.sin_op_in.arg_number; i++) begin
			case(single_input.sin_op_in.cmd)
				cmd_and : begin
					status |= sts_noerr;
					result = result & single_input.sin_op_in.data[(i*8)+:8];
				end
				cmd_or : begin
					status |= sts_noerr;
					result = result | single_input.sin_op_in.data[(i*8)+:8];
				end
				cmd_xor : begin
					status |= sts_noerr;
					result = result ^ single_input.sin_op_in.data[(i*8)+:8];
				end
				cmd_add : begin
					status |= sts_noerr;
					result = result + single_input.sin_op_in.data[(i*8)+:8];
				end
				cmd_sub : begin
					status |= sts_noerr;
					result = result - single_input.sin_op_in.data[(i*8)+:8];
	
				end
				default: begin
					status |= sts_invcmd;
					result = 0;
				end
			endcase
			if (single_input.sin_op_in.data_parity == parity_wrong) begin
				status |= sts_parderr;
				result = 0;	
			end
			if (single_input.sin_op_in.cmd_parity == parity_correct) begin
				status |= sts_parcerr;
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
		out_res.result.data = ret_val;
		return(out_res);
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
    function void write(result_transaction t);
	    
	    string data_str;
        operation_transaction op;
        result_transaction predicted_result;
	    
        do
            if (!op_in.try_get(op))
                $fatal(1, "Missing command in self checker");
        while ((op.sin_op_in.cmd == cmd_nop) || (op.sin_op_in.cmd == cmd_rst));

        predicted_result = get_expected(op);

        data_str  = { op.convert2string(),
            " ==> Rcvd: " , t.convert2string(),
            "/Pred: ",predicted_result.convert2string()};

        if (!predicted_result.compare(t)) begin
            `uvm_error("SLF CHCK", {"FAIL: ",data_str})
            tr = TEST_FAILED;
        end
        else
            `uvm_info ("SLF CHCK", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass

