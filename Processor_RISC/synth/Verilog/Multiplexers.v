localparam Instructions_WB_DATA_MEM = 3'b000;
localparam Instructions_WB_ALU = 3'b001;
localparam Instructions_WB_IMM = 3'b010;
localparam Instructions_WB_PC = 3'b011;

localparam Instructions_AMUX2_REG = 2'b00;
localparam Instructions_AMUX2_IMM = 2'b01;

localparam Instructions_AMUX1_REG = 2'b00;
localparam Instructions_AMUX1_PC = 2'b01;

localparam Instructions_PC_PLUS4 = 2'b00;
localparam Instructions_PC_ALU = 2'b01;
localparam Instructions_PC_IMM = 2'b10;

localparam Instructions_MEM_BYTE_SIGNED = 3'b000;
localparam Instructions_MEM_HALFWORD_SIGNED = 3'b001;
localparam Instructions_MEM_WORD_SIGNED = 3'b010;
localparam Instructions_MEM_BYTE_UNSIGNED = 3'b011;
localparam Instructions_MEM_HALFWORD_UNSIGNED = 3'b100;

module Multiplexers (
	WBSel,
	ALUReg1PCSel,
	ALUReg2ImmSel,
	PCSel,
	wb_mem,
	wb_alu,
	wb_imm,
	wb_pc,
	alu1_reg,
	alu1_pc,
	alu2_reg,
	alu2_imm,
	pc_pc,
	pc_alu,
	pc_imm,
	wb_out,
	alu1_out,
	alu2_out,
	pc_out
);
	input [1:0] WBSel;
	input ALUReg1PCSel;
	input ALUReg2ImmSel;
	input [1:0] PCSel;
	input [31:0] wb_mem;
	input [31:0] wb_alu;
	input [31:0] wb_imm;
	input [31:0] wb_pc;
	input [31:0] alu1_reg;
	input [31:0] alu1_pc;
	input [31:0] alu2_reg;
	input [31:0] alu2_imm;
	input [31:0] pc_pc;
	input [31:0] pc_alu;
	input [31:0] pc_imm;
	output reg [31:0] wb_out;
	output reg [31:0] alu1_out;
	output reg [31:0] alu2_out;
	output reg [31:0] pc_out;
	wire [31:0] pc_plus4;
	wire [31:0] pc_plusImm;
	wire [31:0] wb_plus4;
	wire [31:0] pc_alu_plusPC;
	assign pc_plus4 = pc_pc + 4;
	assign wb_plus4 = wb_pc + 4;
	assign pc_plusImm = pc_pc + pc_imm;
	assign pc_alu_plusPC = pc_alu + pc_pc;
	always @(*) begin : WB_mux
		case (WBSel)
			Instructions_WB_DATA_MEM: wb_out = wb_mem;
			Instructions_WB_ALU: wb_out = wb_alu;
			Instructions_WB_IMM: wb_out = wb_imm;
			Instructions_WB_PC: wb_out = wb_plus4;
		endcase
	end
	always @(*) begin : ALU1_mux
		case (ALUReg1PCSel)
			1'b0: alu1_out = alu1_reg;
			1'b1: alu1_out = alu1_pc;
		endcase
	end
	always @(*) begin : ALU2_mux
		case (ALUReg2ImmSel)
			1'b0: alu2_out = alu2_reg;
			1'b1: alu2_out = alu2_imm;
		endcase
	end
	always @(*) begin : PC_mux
		case (PCSel)
			Instructions_PC_PLUS4: pc_out = pc_plus4;
			Instructions_PC_ALU: pc_out = pc_alu_plusPC;
			Instructions_PC_IMM: pc_out = pc_plusImm;
		endcase
	end
endmodule
