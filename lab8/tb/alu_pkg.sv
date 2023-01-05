//`timescale 1ns/1ps

package alu_pkg;
	
	import uvm_pkg::*;
    `include "uvm_macros.svh"
	
	typedef enum bit[8:0] {
		cmd_nop = 9'b100000000,
		cmd_and = 9'b100000001,
		cmd_or =  9'b100000010,
		cmd_xor = 9'b100000011,
		cmd_add = 9'b100010000,
		cmd_sub = 9'b100100000,
		cmd_inv = 9'b110000000,
		cmd_rst = 9'b111111111
	} command_t;
	
	typedef enum int {
		arg_num_0 = 0,
		arg_num_1 = 1,
		arg_num_2 = 2,
		arg_num_3 = 3,
		arg_num_4 = 4,
		arg_num_5 = 5,
		arg_num_6 = 6,
		arg_num_7 = 7,
		arg_num_8 = 8,
		arg_num_9 = 9,
		arg_num_10 = 10,
		arg_num_11 = 11
	} arg_num_t;
	
	typedef enum logic {
		parity_wrong = 0,
		parity_correct = 1
	} parity_t;
	
	typedef enum {
		all_ones,
		all_zeros,
		random
	} data_value_t;
	
	typedef struct packed{
		command_t			cmd;
		bit [79:0]			data;
		arg_num_t			arg_number;
		parity_t			data_parity;
		parity_t			cmd_parity;
		data_value_t		data_val;
	} single_op_input_t;
	
	typedef struct packed{
		bit [29:0]			data;
	} result_t;
	
	typedef enum bit[8:0] {
		sts_noerr =  9'b100000000,
		sts_invcmd = 9'b110000000,
		sts_parderr = 9'b100100000,
		sts_parcerr = 9'b101000000
	} status_t;
	
	typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;
	
	function void set_print_color ( print_color c );
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

// configs
`include "env_config.svh"
`include "alu_agent_config.svh"

// transactions
`include "operation_transaction.svh"
//`include "max_transaction.svh"
`include "result_transaction.svh"

// testbench components
`include "coverage.svh"
`include "scoreboard.svh"
`include "tester.svh"
`include "driver.svh"
`include "operation_monitor.svh"
`include "result_monitor.svh"
`include "alu_agent.svh"
`include "env.svh"

// tests
`include "dual_test.svh"
	
endpackage : alu_pkg
