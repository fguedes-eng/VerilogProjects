import ALUInstr::*;
import InstrTypes::*;
import Instructions::*;

module Control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] imm,
    output logic regWrite,
    output logic [3:0] ALUop,
    output logic memWrite,
    output logic WBSel,
    output logic ALUReg1PCSel,
    output logic ALUReg2ImmSel,
    output logic PCSel,
    output logic [3:0] memRWSize
);

always @(*) begin
    case (opcode)
        Rtype: begin

            memWrite = 1'b0;
            regWrite = 1'b1;
            WBSel = WB_ALU; //escreve o resultado da operação
            ALUReg1PCSel = AMUX1_REG; //faz operação com reg1 e reg2
            ALUReg2ImmSel = AMUX2_REG; 
            PCSel = PC_PLUS4; //próxima instrução
            memRWSize = 3'bxxx; 

            case ({funct7, funct3})
                
                10'b0000000_000: begin //ADD
                    ALUop = ADD;        
                end

                10'b0100000_000: begin //SUB
                    ALUop = SUB;
                end

                10'b0000000_001: begin //SLL
                    ALUop = SLL;
                end

                10'b0000000_010: begin //SLT
                    ALUop = SLT;
                end

                10'b0000000_011: begin //SLTU
                    ALUop = ULT;
                end

                10'b0000000_100: begin //XOR
                    ALUop = XOR;
                end

                10'b0000000_101: begin //SRL
                    ALUop = SRL;
                end

                10'b0100000_101: begin //SRA
                    ALUop = SRA;
                end

                10'b0000000_110: begin //OR
                    ALUop = OR;
                end

                10'b0000000_111: begin //AND
                    ALUop = AND;
                end

            endcase
        end

        ItypeLd: begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b1; //escreve no reg
            WBSel = WB_DATA_MEM; //escreve em rd o dado na memória com o endereço rs1 + offset
            ALUop = ADD;
            ALUReg1PCSel = AMUX1_REG; //Pega o conteúdo do reg na posição rs1
            ALUReg2ImmSel = AMUX2_IMM; //soma com o valor imediato (offset)
            PCSel = PC_PLUS4; //próxima instrução
            case (funct3)
                000: begin //lb
                    memRWSize = MEM_BYTE_SIGNED;
                end

                001: begin //lh
                    memRWSize = MEM_HALFWORD_SIGNED;
                end

                010: begin //lw
                    memRWSize = MEM_WORD_SIGNED;
                end

                011: begin //lbu
                    memRWSize = MEM_BYTE_UNSIGNED;
                end

                100: begin //lhu
                    memRWSize = MEM_HALFWORD_UNSIGNED;
                end

            endcase
        end

        Stype: begin
            memWrite = 1'b1; //escreve na memória
            regWrite = 1'b0; //não escreve no reg
            WBSel = 2'bxx; //não escreve em rd
            ALUop = ADD;
            ALUReg1PCSel = AMUX1_REG; //Pega o conteúdo do reg na posição rs1
            ALUReg2ImmSel = AMUX2_IMM; //soma com o valor imediato (offset)
            PCSel = PC_PLUS4; //próxima instrução
            case (funct3)
                000: begin //sb
                    memRWSize = MEM_BYTE_SIGNED;
                end

                001: begin //sh
                    memRWSize = MEM_HALFWORD_SIGNED;
                end

                010: begin //sw
                    memRWSize = MEM_WORD_SIGNED;
                end

            endcase
        end

        ItypeImm: begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b1; //escreve no reg
            WBSel = WB_ALU; //escreve em rd
            ALUReg1PCSel = AMUX1_REG; //Pega o conteúdo do reg na posição rs1
            ALUReg2ImmSel = AMUX2_IMM; //opera com o valor imediato
            PCSel = PC_PLUS4; //próxima instrução
            case (funct3)
                3'b000: begin
                    ALUop = ADD;
                end

                3'b010: begin
                    ALUop = SLT;
                end

                3'b011: begin
                    ALUop = ULT;
                end

                3'b100: begin
                    ALUop = XOR;
                end

                3'b110: begin
                    ALUop = OR;
                end

                3'b111: begin
                    ALUop = AND;
                end

                3'b001: begin //uso de shift amount nos lsb de imm
                    if (imm[11:5] == 7'b0000000) begin
                        ALUop = SLL;
                    end else begin
                        ALUop = DEFAULT;
                    end
                end

                3'b101: begin
                    if (imm[11:5] == 7'b0000000) begin
                        ALUop = SRL;
                    end else if (imm[11:5] == 7'b0100000) begin
                        ALUop = SRA;
                    end else begin
                        ALUop = DEFAULT;
                    end
                end
            endcase
        end

        ItypeJALR: begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b1; //escreve no reg
            WBSel = WB_PC; //escreve em rd o endereço da instrução subsequente
            ALUReg1PCSel = AMUX1_REG; //Pega o conteúdo do reg na posição rs1
            ALUReg2ImmSel = AMUX2_IMM; //opera com o valor imediato
            PCSel = PC_ALU; //próxima instrução dada pelo conteúdo do reg + offset
            ALUop = ADD;
        end

        Btype: begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b0; //não escreve no reg
            WBSel = 2'bxx; //não escreve em rd
            ALUReg1PCSel = AMUX1_REG; //Pega o conteúdo do reg na posição rs1
            ALUReg2ImmSel = AMUX2_REG; //Pega o conteúdo do reg na posição rs2
            PCSel = PC_IMM; //próxima instruação dada pelo conteúdo do PC atual + offset (valor imediato)

            case (funct3)
                3'b000: begin //BEQ
                    ALUop = EQ;
                end

                3'b001: begin //BNE
                    ALUop = EQ;
                end

                3'b100: begin //BLT
                    ALUop = ULT;
                end

                3'b101: begin //BGE
                    ALUop = UGTE;
                end

                3'b110: begin //BLTU
                    ALUop = SLT;
                end

                3'b111: begin //BGEU
                    ALUop = SGTE;
                end
            endcase
        end

        UtypeLUI:  begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b1; //escreve no reg
            WBSel = WB_IMM; //escreve em rd valor do imm
            ALUReg1PCSel = 1'bx; //Não usa ALU
            ALUReg2ImmSel = 1'bx; //Não usa ALU
            PCSel = PC_PLUS4; //próxima instrução
            ALUop = 4'bxxxx; //Não usa ALU
        end

        UtypeAUIPC: begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b1; //escreve no reg
            WBSel = WB_ALU; //escreve em rd soma do PC + imm
            ALUReg1PCSel = AMUX1_PC; //Pega o conteúdo do PC
            ALUReg2ImmSel = AMUX2_IMM; //Pega o valor imediato shiftado de 12 (upper)
            PCSel = PC_PLUS4; //próxima instrução
            ALUop = ADD;
        end

        Jtype: begin
            memWrite = 1'b0; //não escreve na memória
            regWrite = 1'b1; //escreve no reg
            WBSel = WB_PC; //escreve em rd o endereço da instrução subsequente
            ALUReg1PCSel = 1'bx; //Não usa ALU
            ALUReg2ImmSel = 1'bx; //Não usa ALU
            PCSel = PC_IMM; // próxima instrução determinada pelo valor imediato
            ALUop = 4'bxxxx; //Não usa ALU
        end

    endcase
end

endmodule