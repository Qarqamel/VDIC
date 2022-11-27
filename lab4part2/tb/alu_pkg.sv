//`timescale 1ns/1ps

package alu_pkg;
	
	typedef enum bit[9:0] {
		cmd_nop = 10'b1000000001,
		cmd_and = 10'b1000000010,
		cmd_or =  10'b1000000100,
		cmd_xor = 10'b1000000111,
		cmd_add = 10'b1000100000,
		cmd_sub = 10'b1001000000,
		cmd_inv = 10'b1100000000,
		cmd_rst = 10'b1111111111
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
		arg_num_10 = 10
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
	
	 typedef struct {
		command_t			cmd;
		bit [99:0]			data;
		arg_num_t			arg_number;
		parity_t			parity;
		data_value_t		data_val;
	} single_op_input_t;
	
	typedef enum bit[8:0] {
		sts_noerr =  9'b100000000,
		sts_invcmd = 9'b110000000,
		sts_parerr = 9'b100100000
	} status_t;
	
`include "coverage.svh"
`include "tester.svh"
`include "scoreboard.svh"
`include "testbench.svh"
	
endpackage : alu_pkg
