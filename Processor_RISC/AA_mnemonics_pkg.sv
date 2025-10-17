    package InstrTypes;

        parameter Rtype        = 7'b0110011;
        parameter ItypeImm     = 7'b0010011;
        parameter ItypeLd      = 7'b0000011;
        parameter ItypeJALR    = 7'b1100111;
        parameter Stype        = 7'b0100011;
        parameter Btype        = 7'b1100011;
        parameter UtypeLUI     = 7'b0110111;
        parameter UtypeAUIPC   = 7'b0010111;
        parameter Jtype        = 7'b1101111;

    endpackage

    package ALUInstr;

        parameter ADD  = 4'b0000;
        parameter SUB  = 4'b0001;
        parameter SLL  = 4'b0010;
        parameter SRL  = 4'b0011;
        parameter SRA  = 4'b0100;
        parameter OR   = 4'b0101;
        parameter AND  = 4'b0110;
        parameter XOR  = 4'b0111;
        parameter SLT  = 4'b1000;
        parameter ULT  = 4'b1001;
        parameter UGTE = 4'b1010;
        parameter EQ   = 4'b1011;
        parameter SGTE = 4'b1100;
        parameter DEFAULT = 4'b1111;

    endpackage

    package Instructions;
        enum {
            WB_DATA_MEM,
            WB_ALU,
            WB_IMM,
            WB_PC
        } WB;

        enum {
            AMUX2_REG,
            AMUX2_IMM
        } AMUX2;

        enum {
            AMUX1_REG,
            AMUX1_PC
        } AMUX1;

        enum {
            PC_PLUS4,
            PC_ALU,
            PC_IMM
        } PC;

        enum {
            MEM_BYTE_SIGNED,
            MEM_HALFWORD_SIGNED,
            MEM_WORD_SIGNED,
            MEM_BYTE_UNSIGNED,
            MEM_HALFWORD_UNSIGNED
        } MEM_RW_SIZE;
    endpackage
