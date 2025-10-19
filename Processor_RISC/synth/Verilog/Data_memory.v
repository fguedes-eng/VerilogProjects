localparam Instructions_MEM_BYTE_SIGNED = 3'b000;
localparam Instructions_MEM_HALFWORD_SIGNED = 3'b001;
localparam Instructions_MEM_WORD_SIGNED = 3'b010;
localparam Instructions_MEM_BYTE_UNSIGNED = 3'b011;
localparam Instructions_MEM_HALFWORD_UNSIGNED = 3'b100;

module Data_memory (
	clk,
	rst,
	mem_addr,
	wr_data,
	we,
	read_size,
	rd_data
);
	input clk;
	input rst;
	input [11:0] mem_addr;
	input [31:0] wr_data;
	input we;
	input [2:0] read_size;
	output reg [31:0] rd_data;
	reg [7:0] mem_cell [0:1023];
	always @(*)
		case (read_size)
			Instructions_MEM_BYTE_SIGNED: rd_data = {{24 {mem_cell[mem_addr][7]}}, mem_cell[mem_addr]};
			Instructions_MEM_HALFWORD_SIGNED: rd_data = {{16 {mem_cell[mem_addr][7]}}, mem_cell[mem_addr], mem_cell[mem_addr + 1]};
			Instructions_MEM_WORD_SIGNED: rd_data = {mem_cell[mem_addr], mem_cell[mem_addr + 1], mem_cell[mem_addr + 2], mem_cell[mem_addr + 3]};
			Instructions_MEM_BYTE_UNSIGNED: rd_data = {24'd0, mem_cell[mem_addr]};
			Instructions_MEM_HALFWORD_UNSIGNED: rd_data = {16'd0, mem_cell[mem_addr], mem_cell[mem_addr + 1]};
		endcase
	always @(posedge clk)
		if (we)
			case (read_size)
				Instructions_MEM_BYTE_SIGNED, Instructions_MEM_BYTE_UNSIGNED: mem_cell[mem_addr] <= wr_data[7:0];
				Instructions_MEM_HALFWORD_SIGNED, Instructions_MEM_HALFWORD_UNSIGNED: {mem_cell[mem_addr], mem_cell[mem_addr + 1]} <= wr_data[15:0];
				Instructions_MEM_WORD_SIGNED: {mem_cell[mem_addr], mem_cell[mem_addr + 1], mem_cell[mem_addr + 2], mem_cell[mem_addr + 3]} <= wr_data;
			endcase
endmodule
