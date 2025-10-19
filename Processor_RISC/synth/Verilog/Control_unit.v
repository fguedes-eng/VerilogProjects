module Control_unit (
	opcode,
	funct3,
	funct7,
	imm,
	regWrite,
	ALUop,
	memWrite,
	WBSel,
	ALUReg1PCSel,
	ALUReg2ImmSel,
	PCSel,
	memRWSize
);
	input [6:0] opcode;
	input [2:0] funct3;
	input [6:0] funct7;
	input [31:0] imm;
	output reg regWrite;
	output reg [3:0] ALUop;
	output reg memWrite;
	output reg [1:0] WBSel;
	output reg ALUReg1PCSel;
	output reg ALUReg2ImmSel;
	output reg [1:0] PCSel;
	output reg [2:0] memRWSize;
	localparam ALUInstr_ADD = 4'b0000;
	localparam ALUInstr_AND = 4'b0110;
	localparam ALUInstr_DEFAULT = 4'b1111;
	localparam ALUInstr_EQ = 4'b1011;
	localparam ALUInstr_OR = 4'b0101;
	localparam ALUInstr_SGTE = 4'b1100;
	localparam ALUInstr_SLL = 4'b0010;
	localparam ALUInstr_SLT = 4'b1000;
	localparam ALUInstr_SRA = 4'b0100;
	localparam ALUInstr_SRL = 4'b0011;
	localparam ALUInstr_SUB = 4'b0001;
	localparam ALUInstr_UGTE = 4'b1010;
	localparam ALUInstr_ULT = 4'b1001;
	localparam ALUInstr_XOR = 4'b0111;
	localparam InstrTypes_Btype = 7'b1100011;
	localparam InstrTypes_ItypeImm = 7'b0010011;
	localparam InstrTypes_ItypeJALR = 7'b1100111;
	localparam InstrTypes_ItypeLd = 7'b0000011;
	localparam InstrTypes_Jtype = 7'b1101111;
	localparam InstrTypes_Rtype = 7'b0110011;
	localparam InstrTypes_Stype = 7'b0100011;
	localparam InstrTypes_UtypeAUIPC = 7'b0010111;
	localparam InstrTypes_UtypeLUI = 7'b0110111;
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
	always @(*)
		case (opcode)
			InstrTypes_Rtype: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_ALU;
				ALUReg1PCSel = Instructions_AMUX1_REG;
				ALUReg2ImmSel = Instructions_AMUX2_REG;
				PCSel = Instructions_PC_PLUS4;
				memRWSize = 3'bxxx;
				case ({funct7, funct3})
					10'b0000000000: ALUop = ALUInstr_ADD;
					10'b0100000000: ALUop = ALUInstr_SUB;
					10'b0000000001: ALUop = ALUInstr_SLL;
					10'b0000000010: ALUop = ALUInstr_SLT;
					10'b0000000011: ALUop = ALUInstr_ULT;
					10'b0000000100: ALUop = ALUInstr_XOR;
					10'b0000000101: ALUop = ALUInstr_SRL;
					10'b0100000101: ALUop = ALUInstr_SRA;
					10'b0000000110: ALUop = ALUInstr_OR;
					10'b0000000111: ALUop = ALUInstr_AND;
				endcase
			end
			InstrTypes_ItypeLd: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_DATA_MEM;
				ALUop = ALUInstr_ADD;
				ALUReg1PCSel = Instructions_AMUX1_REG;
				ALUReg2ImmSel = Instructions_AMUX2_IMM;
				PCSel = Instructions_PC_PLUS4;
				case (funct3)
					0: memRWSize = Instructions_MEM_BYTE_SIGNED;
					1: memRWSize = Instructions_MEM_HALFWORD_SIGNED;
					10: memRWSize = Instructions_MEM_WORD_SIGNED;
					11: memRWSize = Instructions_MEM_BYTE_UNSIGNED;
					100: memRWSize = Instructions_MEM_HALFWORD_UNSIGNED;
				endcase
			end
			InstrTypes_Stype: begin
				memWrite = 1'b1;
				regWrite = 1'b0;
				WBSel = 2'bxx;
				ALUop = ALUInstr_ADD;
				ALUReg1PCSel = Instructions_AMUX1_REG;
				ALUReg2ImmSel = Instructions_AMUX2_IMM;
				PCSel = Instructions_PC_PLUS4;
				case (funct3)
					0: memRWSize = Instructions_MEM_BYTE_SIGNED;
					1: memRWSize = Instructions_MEM_HALFWORD_SIGNED;
					10: memRWSize = Instructions_MEM_WORD_SIGNED;
				endcase
			end
			InstrTypes_ItypeImm: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_ALU;
				ALUReg1PCSel = Instructions_AMUX1_REG;
				ALUReg2ImmSel = Instructions_AMUX2_IMM;
				PCSel = Instructions_PC_PLUS4;
				memRWSize = 3'bxxx;
				case (funct3)
					3'b000: ALUop = ALUInstr_ADD;
					3'b010: ALUop = ALUInstr_SLT;
					3'b011: ALUop = ALUInstr_ULT;
					3'b100: ALUop = ALUInstr_XOR;
					3'b110: ALUop = ALUInstr_OR;
					3'b111: ALUop = ALUInstr_AND;
					3'b001:
						if (imm[11:5] == 7'b0000000)
							ALUop = ALUInstr_SLL;
						else
							ALUop = ALUInstr_DEFAULT;
					3'b101:
						if (imm[11:5] == 7'b0000000)
							ALUop = ALUInstr_SRL;
						else if (imm[11:5] == 7'b0100000)
							ALUop = ALUInstr_SRA;
						else
							ALUop = ALUInstr_DEFAULT;
				endcase
			end
			InstrTypes_ItypeJALR: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_PC;
				ALUReg1PCSel = Instructions_AMUX1_REG;
				ALUReg2ImmSel = Instructions_AMUX2_IMM;
				PCSel = Instructions_PC_ALU;
				ALUop = ALUInstr_ADD;
				memRWSize = 3'bxxx;
			end
			InstrTypes_Btype: begin
				memWrite = 1'b0;
				regWrite = 1'b0;
				WBSel = 2'bxx;
				ALUReg1PCSel = Instructions_AMUX1_REG;
				ALUReg2ImmSel = Instructions_AMUX2_REG;
				PCSel = Instructions_PC_IMM;
				memRWSize = 3'bxxx;
				case (funct3)
					3'b000: ALUop = ALUInstr_EQ;
					3'b001: ALUop = ALUInstr_EQ;
					3'b100: ALUop = ALUInstr_ULT;
					3'b101: ALUop = ALUInstr_UGTE;
					3'b110: ALUop = ALUInstr_SLT;
					3'b111: ALUop = ALUInstr_SGTE;
				endcase
			end
			InstrTypes_UtypeLUI: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_IMM;
				ALUReg1PCSel = 1'bx;
				ALUReg2ImmSel = 1'bx;
				PCSel = Instructions_PC_PLUS4;
				ALUop = 4'bxxxx;
				memRWSize = 3'bxxx;
			end
			InstrTypes_UtypeAUIPC: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_ALU;
				ALUReg1PCSel = Instructions_AMUX1_PC;
				ALUReg2ImmSel = Instructions_AMUX2_IMM;
				PCSel = Instructions_PC_PLUS4;
				ALUop = ALUInstr_ADD;
				memRWSize = 3'bxxx;
			end
			InstrTypes_Jtype: begin
				memWrite = 1'b0;
				regWrite = 1'b1;
				WBSel = Instructions_WB_PC;
				ALUReg1PCSel = 1'bx;
				ALUReg2ImmSel = 1'bx;
				PCSel = Instructions_PC_IMM;
				ALUop = 4'bxxxx;
				memRWSize = 3'bxxx;
			end
		endcase
endmodule
