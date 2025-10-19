module Instruction_memory (
	addr,
	mem_input,
	rd
);
	input [9:0] addr;
	input [8191:0] mem_input;
	output wire [31:0] rd;
	wire [8191:0] mem;
	assign mem = mem_input;
	assign rd = mem[(255 - (addr >> 2)) * 32+:32];
endmodule
