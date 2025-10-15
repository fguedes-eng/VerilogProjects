import InstrTypes::*;

module Instruction_decoder (
    input [31:0] instruction,
    output logic [6:0] opcode,
    output logic [4:0] rd,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [31:0] imm
);

assign opcode = instruction[6:0];

always @(*) begin
    case (opcode)
        Rtype: begin
            rd          = instruction[11:7];
            funct3      = instruction[14:12];
            rs1         = instruction[19:15];
            rs2         = instruction[24:20];
            funct7      = instruction[31:25];
        end

        ItypeImm, ItypeLd, ItypeJALR: begin
            rd          = instruction[11:7];
            funct3      = instruction[14:12];
            rs1         = instruction[19:15];
            imm         = {{20{instruction[31]}}, instruction[31:20]};
        end

        Stype: begin
            funct3      = instruction[14:12];
            rs1         = instruction[19:15];
            rs2         = instruction[24:20];
            imm         = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        end

        Btype: begin
            funct3      = instruction[14:12];
            rs1         = instruction[19:15];
            rs2         = instruction[24:20];
            imm         = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        end

        UtypeLUI, UtypeAUIPC: begin
            rd          = instruction[11:7];
            imm         = {instruction[31:12], 12'b0000_0000_0000};
        end

        Jtype: begin
            rd          = instruction[11:7];
            imm         = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        end
    endcase
end

/*
opcode R-Type = 0110011
opcode I-Type = 0010011 -> operações imediatas
              = 0000011 -> loads
              = 1100111 -> JALR
opcode S-Type = 0100011
opcode B-Type = 1100011
opcode U-Type = 0110111 -> LUI
              = 0010111 -> AUIPC
opcode J-Type = 1101111
*/
endmodule