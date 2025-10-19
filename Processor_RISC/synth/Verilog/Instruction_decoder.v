module Instruction_decoder (
	instruction,
	opcode,
	rd,
	rs1,
	rs2,
	funct3,
	funct7,
	imm
);
	input [31:0] instruction;
	output wire [6:0] opcode;
	output reg [4:0] rd;
	output reg [4:0] rs1;
	output reg [4:0] rs2;
	output reg [2:0] funct3;
	output reg [6:0] funct7;
	output reg [31:0] imm;
	assign opcode = instruction[6:0];
	localparam InstrTypes_Btype = 7'b1100011;
	localparam InstrTypes_ItypeImm = 7'b0010011;
	localparam InstrTypes_ItypeJALR = 7'b1100111;
	localparam InstrTypes_ItypeLd = 7'b0000011;
	localparam InstrTypes_Jtype = 7'b1101111;
	localparam InstrTypes_Rtype = 7'b0110011;
	localparam InstrTypes_Stype = 7'b0100011;
	localparam InstrTypes_UtypeAUIPC = 7'b0010111;
	localparam InstrTypes_UtypeLUI = 7'b0110111;
	always @(*)
		case (opcode)
			InstrTypes_Rtype: begin
				rd = instruction[11:7];
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				funct7 = instruction[31:25];
			end
			InstrTypes_ItypeImm, InstrTypes_ItypeLd, InstrTypes_ItypeJALR: begin
				rd = instruction[11:7];
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				imm = {{20 {instruction[31]}}, instruction[31:20]};
			end
			InstrTypes_Stype: begin
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				imm = {{20 {instruction[31]}}, instruction[31:25], instruction[11:7]};
			end
			InstrTypes_Btype: begin
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				imm = {{19 {instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			end
			InstrTypes_UtypeLUI, InstrTypes_UtypeAUIPC: begin
				rd = instruction[11:7];
				imm = {instruction[31:12], 12'b000000000000};
			end
			InstrTypes_Jtype: begin
				rd = instruction[11:7];
				imm = {{11 {instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			end
		endcase
endmodule
