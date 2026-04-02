// ======================================================
// PACOTE UVM  riscv_uvm_pkg.sv
// ======================================================
package riscv_uvm_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

// ======================================================
// SEQUENCE ITEM
// ======================================================
class riscv_item extends uvm_sequence_item;

    rand bit [31:0] instr [0:31];

    `uvm_object_utils(riscv_item)

    function new(string name = "riscv_item");
        super.new(name);
    endfunction

    // --------------------------------------------------
    // Garante que será gerado um opcode válido
    // --------------------------------------------------
    constraint c_valid_opcode {
        foreach (instr[i]) {
            instr[i][6:0] inside {
                7'b0110011, // R-type
                7'b0010011, // I-type ALU
                7'b0000011, // LOAD
                7'b0100011, // STORE
                7'b1100011, // BRANCH
                7'b1101111, // JAL
                7'b1100111, // JALR
                7'b0110111, // LUI
                7'b0010111  // AUIPC
            };
        }
    }

    // rd != x0
    constraint c_rd_not_zero {
        foreach (instr[i]) {
            instr[i][11:7] != 5'd0;
        }
    }

    // rs1/rs2 completamente livres
    constraint c_rs_range {
        foreach (instr[i]) {
            instr[i][19:15] inside {[5'd0 : 5'd31]};
            instr[i][24:20] inside {[5'd0 : 5'd31]};
        }
    }

    // --------------------------------------------------
    // R-type: apenas combinações (funct7, funct3) válidas.
    //   funct7=0000000: ADD SLL SLT SLTU XOR SRL OR AND
    //   funct7=0100000: SUB (funct3=000) e SRA (funct3=101)
    // Qualquer outro par é encoding indefinido
    // --------------------------------------------------
    constraint c_rtype_funct7 {
        foreach (instr[i]) {
            if (instr[i][6:0] == 7'b0110011) {
                instr[i][31:25] inside {7'b0000000, 7'b0100000};
                (instr[i][31:25] == 7'b0100000) ->
                    (instr[i][14:12] inside {3'b000, 3'b101});
            }
        }
    }

    // --------------------------------------------------
    // I-type shifts (SLLI/SRLI/SRAI): imm[11:5] válido.
    // --------------------------------------------------
    constraint c_itype_shift_funct7 {
        foreach (instr[i]) {
            if (instr[i][6:0] == 7'b0010011) {
                (instr[i][14:12] == 3'b001) ->
                    (instr[i][31:25] == 7'b0000000);
                (instr[i][14:12] == 3'b101) ->
                    (instr[i][31:25] inside {7'b0000000, 7'b0100000});
            }
        }
    }

    // --------------------------------------------------
    // LOAD/STORE: apenas LW/SW (funct3=010).
    // --------------------------------------------------
    constraint c_load_store_word_only {
        foreach (instr[i]) {
            (instr[i][6:0] == 7'b0000011) ->
                (instr[i][14:12] == 3'b010); // LW
            (instr[i][6:0] == 7'b0100011) ->
                (instr[i][14:12] == 3'b010); // SW
        }
    }

    // --------------------------------------------------
    // LOAD/STORE: imediato zero E rs1=x0.
    // --------------------------------------------------
    constraint c_mem_imm_zero {
        foreach (instr[i]) {
            (instr[i][6:0] == 7'b0000011) -> {
                instr[i][31:20] == 12'd0;
                instr[i][19:15] == 5'd0;
            }
            (instr[i][6:0] == 7'b0100011) -> {
                instr[i][31:25] == 7'd0;
                instr[i][11:7]  == 5'd0;
                instr[i][19:15] == 5'd0;
            }
        }
    }

    // --------------------------------------------------
    // JAL: imediato positivo pequeno, forward, alinhado.
    // --------------------------------------------------
    constraint c_jal_range {
        foreach (instr[i]) {
            (instr[i][6:0] == 7'b1101111) -> {
                instr[i][31]    == 1'b0;
                instr[i][19:12] == 8'b0;
                instr[i][20]    == 1'b0;
                instr[i][21]    == 1'b0;
                instr[i][30:25] == 6'b0;
                instr[i][24:22] != 3'b000;
            }
        }
    }

    // --------------------------------------------------
    // JALR: imm controlado, rs1=x0, alinhado.
    // --------------------------------------------------
    constraint c_jalr_range {
        foreach (instr[i]) {
            (instr[i][6:0] == 7'b1100111) -> {
                instr[i][14:12] == 3'b000;
                instr[i][19:15] == 5'd0;
                instr[i][31]    == 1'b0;
                instr[i][30:25] == 6'b0;
                instr[i][22]    == 1'b0;
                instr[i][21]    == 1'b0;
                instr[i][20]    == 1'b0;
            }
        }
    }

    // --------------------------------------------------
    // BRANCH: imediato B-type positivo, alinhado.
    // --------------------------------------------------
    constraint c_branch_range {
        foreach (instr[i]) {
            (instr[i][6:0] == 7'b1100011) -> {
                instr[i][31]    == 1'b0;
                instr[i][7]     == 1'b0;
                instr[i][30:25] == 6'b0;
                instr[i][8]     == 1'b0;
            }
        }
    }

    // --------------------------------------------------
    // Distribuição de opcodes
    // --------------------------------------------------
    constraint c_opcode_dist {
        foreach (instr[i]) {
            instr[i][6:0] dist {
                7'b0110011 := 20, // R-type
                7'b0010011 := 20, // I-type ALU
                7'b0000011 := 10, // LOAD
                7'b0100011 := 10, // STORE
                7'b1100011 := 10, // BRANCH
                7'b1101111 :=  5, // JAL
                7'b1100111 :=  5, // JALR
                7'b0110111 := 10, // LUI
                7'b0010111 := 10  // AUIPC
            };
        }
    }

endclass


// ======================================================
// MONITOR TRANSACTION
// ======================================================
class riscv_transaction extends uvm_sequence_item;

    bit [31:0] pc;
    bit [31:0] instruction;
    bit        regWrite;
    bit [4:0]  rd;
    bit [31:0] wb_data;
    bit        memWrite;
    bit [31:0] alu_out;
    bit        is_seq_start;

    `uvm_object_utils_begin(riscv_transaction)
        `uvm_field_int(pc,           UVM_ALL_ON)
        `uvm_field_int(instruction,  UVM_ALL_ON)
        `uvm_field_int(regWrite,     UVM_ALL_ON)
        `uvm_field_int(rd,           UVM_ALL_ON)
        `uvm_field_int(wb_data,      UVM_ALL_ON)
        `uvm_field_int(memWrite,     UVM_ALL_ON)
        `uvm_field_int(alu_out,      UVM_ALL_ON)
        `uvm_field_int(is_seq_start, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "riscv_transaction");
        super.new(name);
    endfunction

endclass


// ======================================================
// SEQUENCE
// ======================================================
class riscv_base_sequence extends uvm_sequence #(riscv_item);

    `uvm_object_utils(riscv_base_sequence)

    int unsigned num_transactions = 10;

    function new(string name = "riscv_base_sequence");
        super.new(name);
    endfunction

    task body();
        riscv_item item;
        repeat (num_transactions) begin
            item = riscv_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal("SEQ", "Falha ao randomizar riscv_item")
            finish_item(item);
        end
    endtask

endclass


// ======================================================
// DRIVER
// ======================================================
class riscv_driver extends uvm_driver #(riscv_item);

    `uvm_component_utils(riscv_driver)

    virtual riscv_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual riscv_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Interface nao encontrada no config_db")
    endfunction

    task run_phase(uvm_phase phase);
        riscv_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(riscv_item item);
        int i;
        // Preenche toda a memória com NOP antes de cada transação.
        // NOP = ORI x1, x0, 0 (0x00006093)
        for (i = 0; i < 256; i++)
            vif.mem_input[i] = 32'h0000_6093;

        for (i = 0; i < 32; i++)
            vif.mem_input[i] = item.instr[i];

        // Reset síncrono de 5 ciclos
        vif.rst = 1'b1;
      repeat (5) @(posedge vif.clk);

        @(negedge vif.clk);
        vif.rst = 1'b0;

        // 32 instruções + 4 NOPs de margem
        repeat (36) @(posedge vif.clk);
    endtask

endclass


// ======================================================
// MONITOR
// ======================================================
class riscv_monitor extends uvm_component;

    `uvm_component_utils(riscv_monitor)

    virtual riscv_if vif;
    uvm_analysis_port #(riscv_transaction) analysis_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual riscv_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Interface nao encontrada no config_db")
    endfunction

    task run_phase(uvm_phase phase);
        riscv_transaction tr;
        bit first_in_seq;
        forever begin
            @(posedge vif.rst);
            @(negedge vif.rst);
            @(posedge vif.clk);
            #1;

            first_in_seq = 1'b1;
            while (!vif.rst) begin
                tr = riscv_transaction::type_id::create("tr");
                tr.pc           = vif.pc;
                tr.instruction  = vif.instruction;
                tr.regWrite     = vif.regWrite;
                tr.rd           = vif.rd;
                tr.wb_data      = vif.wb_data;
                tr.memWrite     = vif.memWrite;
                tr.alu_out      = vif.ALUout;
                tr.is_seq_start = first_in_seq;
                first_in_seq    = 1'b0;

                //`uvm_info("WB",
                //    $sformatf("PC=%08h instr=%08h rd=x%0d wb_data=%08h",
                //    vif.pc, vif.instruction, vif.rd, vif.wb_data),
                //    UVM_LOW)

                analysis_port.write(tr);
                @(posedge vif.clk);
                #1;
            end
        end
    endtask

endclass


// ======================================================
// SCOREBOARD
// ======================================================
class riscv_scoreboard extends uvm_component;

    `uvm_component_utils(riscv_scoreboard)

    uvm_analysis_imp #(riscv_transaction, riscv_scoreboard) analysis_export;

    bit [31:0] regfile [32];

    int unsigned errors;
    int unsigned checks;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reset_model();
    endfunction

    function void reset_model();
        foreach (regfile[i]) regfile[i] = 32'd0;
    endfunction

    // --------------------------------------------------
    // Decodifica instrução para string
    // --------------------------------------------------
    function string decode_instr(bit [31:0] instr);
        bit [6:0] op     = instr[6:0];
        bit [4:0] rd     = instr[11:7];
        bit [2:0] f3     = instr[14:12];
        bit [4:0] rs1    = instr[19:15];
        bit [4:0] rs2    = instr[24:20];
        bit [6:0] f7     = instr[31:25];
        bit signed [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
        string mnem;
        case (op)
            7'b0110011: begin
                case ({f7[5], f3})
                    4'b0_000: mnem = "ADD";  4'b1_000: mnem = "SUB";
                    4'b0_001: mnem = "SLL";  4'b0_010: mnem = "SLT";
                    4'b0_011: mnem = "SLTU"; 4'b0_100: mnem = "XOR";
                    4'b0_101: mnem = "SRL";  4'b1_101: mnem = "SRA";
                    4'b0_110: mnem = "OR";   4'b0_111: mnem = "AND";
                    default:  mnem = "R?";
                endcase
                return $sformatf("%s x%0d,x%0d(=%0h),x%0d(=%0h)",
                    mnem, rd, rs1, regfile[rs1], rs2, regfile[rs2]);
            end
            7'b0010011: begin
                case (f3)
                    3'b000: mnem = "ADDI";  3'b010: mnem = "SLTI";
                    3'b011: mnem = "SLTIU"; 3'b100: mnem = "XORI";
                    3'b110: mnem = "ORI";   3'b111: mnem = "ANDI";
                    3'b001: mnem = "SLLI";  3'b101: mnem = instr[30] ? "SRAI":"SRLI";
                    default: mnem = "I?";
                endcase
                return $sformatf("%s x%0d,x%0d(=%0h),imm=%0h",
                    mnem, rd, rs1, regfile[rs1], imm_i);
            end
            7'b0000011: return $sformatf("LOAD  x%0d,[x%0d(=%0h)+%0h]",
                                rd, rs1, regfile[rs1], imm_i);
            7'b0100011: return $sformatf("STORE [x%0d(=%0h)+%0h],x%0d(=%0h)",
                                rs1, regfile[rs1], imm_i, rs2, regfile[rs2]);
            7'b1100011: begin
                case (f3)
                    3'b000: mnem="BEQ"; 3'b001: mnem="BNE";
                    3'b100: mnem="BLT"; 3'b101: mnem="BGE";
                    3'b110: mnem="BLTU";3'b111: mnem="BGEU";
                    default: mnem="B?";
                endcase
                return $sformatf("%s x%0d(=%0h),x%0d(=%0h)",
                    mnem, rs1, regfile[rs1], rs2, regfile[rs2]);
            end
            7'b1101111: return $sformatf("JAL   x%0d", rd);
            7'b1100111: return $sformatf("JALR  x%0d,[x%0d(=%0h)+%0h]",
                                rd, rs1, regfile[rs1], imm_i);
            7'b0110111: return $sformatf("LUI   x%0d,0x%0h", rd, instr[31:12]);
            7'b0010111: return $sformatf("AUIPC x%0d,0x%0h", rd, instr[31:12]);
            default:    return $sformatf("UNK(%07b)", op);
        endcase
    endfunction

    // --------------------------------------------------
    // write()  chamado pelo monitor a cada ciclo
    // --------------------------------------------------
    function void write(riscv_transaction tr);
        bit [6:0]  opcode;
        bit [31:0] expected_wb;
        bit        do_check;

        if (tr.is_seq_start)
            reset_model();

        // Ignora NOPs de enchimento (ORI x1, x0, 0 = 0x00006093)
        if (tr.instruction == 32'h0000_6093)
            return;

        opcode      = tr.instruction[6:0];
        do_check    = 1'b0;
        expected_wb = 32'hx;

        case (opcode)

            7'b0110011: begin
                expected_wb = predict_rtype(tr.instruction);
                do_check    = tr.regWrite;
            end

            7'b0010011: begin
                expected_wb = predict_itype_alu(tr.instruction);
                do_check    = tr.regWrite;
            end

            7'b0000011: begin
                do_check    = tr.regWrite;
                expected_wb = tr.wb_data;
                if ($isunknown(tr.wb_data))
                    `uvm_error("SB_LOAD", $sformatf(
                        "LOAD X/Z: pc=%0h [%s]", tr.pc,
                        decode_instr(tr.instruction)))
            end

            7'b0100011: begin
                do_check = 1'b0;
                if (tr.regWrite)
                    `uvm_error("SB_STORE", $sformatf(
                        "STORE com regWrite=1: pc=%0h [%s]",
                        tr.pc, decode_instr(tr.instruction)))
            end

            7'b1100011: begin
                do_check = 1'b0;
                if (tr.regWrite)
                    `uvm_error("SB_BRANCH", $sformatf(
                        "BRANCH com regWrite=1: pc=%0h [%s]",
                        tr.pc, decode_instr(tr.instruction)))
            end

            7'b1101111: begin
                expected_wb = tr.pc + 4;
                do_check    = tr.regWrite;
            end

            7'b1100111: begin
                expected_wb = tr.pc + 4;
                do_check    = tr.regWrite;
            end

            7'b0110111: begin
                expected_wb = {tr.instruction[31:12], 12'b0};
                do_check    = tr.regWrite;
            end

            7'b0010111: begin
                expected_wb = tr.pc + {tr.instruction[31:12], 12'b0};
                do_check    = tr.regWrite;
            end

            default:
                `uvm_warning("SB_UNK", $sformatf(
                    "Opcode desconhecido: %07b pc=%0h", opcode, tr.pc))

        endcase

        if (do_check) begin
            checks++;
            if (tr.rd == 5'd0) begin
                `uvm_error("SB_X0", $sformatf(
                    "Escrita em x0: pc=%0h [%s]",
                    tr.pc, decode_instr(tr.instruction)))
                errors++;
            end else if (!$isunknown(expected_wb) &&
                         (tr.wb_data !== expected_wb)) begin
                `uvm_error("SB_MISMATCH", $sformatf(
                    "MISMATCH x%0d: pc=%0h | %s | esp=0x%0h obt=0x%0h | delta=0x%0h",
                    tr.rd, tr.pc,
                    decode_instr(tr.instruction),
                    expected_wb, tr.wb_data,
                    expected_wb ^ tr.wb_data))
                errors++;
            end
        end

        commit(tr);

    endfunction

    // --------------------------------------------------
    // PREDICT
    // --------------------------------------------------
    function bit [31:0] predict_rtype(bit [31:0] instr);
        bit [4:0]  rs1, rs2;
        bit [2:0]  funct3;
        bit        sub;
        bit [31:0] a, b;
        rs1    = instr[19:15];
        rs2    = instr[24:20];
        funct3 = instr[14:12];
        sub    = instr[30];
        a = regfile[rs1];
        b = regfile[rs2];
        case (funct3)
            3'b000: return sub ? (a - b) : (a + b);
            3'b001: return a << b[4:0];
            3'b010: return {{31{1'b0}}, ($signed(a) < $signed(b))};
            3'b011: return {{31{1'b0}}, (a < b)};
            3'b100: return a ^ b;
            3'b101: return sub ?
                        (32'($signed(a) >>> b[4:0])) :
                        (a >> b[4:0]);
            3'b110: return a | b;
            3'b111: return a & b;
            default: return 32'hx;
        endcase
    endfunction

    function bit [31:0] predict_itype_alu(bit [31:0] instr);
        bit [4:0]         rs1;
        bit [2:0]         funct3;
        bit               arith;
        bit signed [31:0] imm;
        bit [31:0]        a;
        bit [4:0]         shamt;
        rs1    = instr[19:15];
        funct3 = instr[14:12];
        arith  = instr[30];
        imm    = {{20{instr[31]}}, instr[31:20]};
        a      = regfile[rs1];
        shamt  = instr[24:20];
        case (funct3)
            3'b000: return a + imm;
            3'b001: return a << shamt;
            3'b010: return {{31{1'b0}}, ($signed(a) < $signed(imm))};
            3'b011: return {{31{1'b0}}, (a < 32'(unsigned'(imm)))};
            3'b100: return a ^ imm;
            3'b101: return arith ?
                        (32'($signed(a) >>> shamt)) :
                        (a >> shamt);
            3'b110: return a | imm;
            3'b111: return a & imm;
            default: return 32'hx;
        endcase
    endfunction

    // --------------------------------------------------
    // COMMIT
    // --------------------------------------------------
    function void commit(riscv_transaction tr);
        bit [6:0] opcode = tr.instruction[6:0];
        bit [4:0] rd     = tr.instruction[11:7];

        case (opcode)
            7'b0110011, 7'b0010011,
            7'b0000011,
            7'b1101111, 7'b1100111,
            7'b0110111, 7'b0010111:
                if (rd != 0 && tr.regWrite) regfile[rd] = tr.wb_data;
            default: ;
        endcase

        regfile[0] = 32'd0;

    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", $sformatf(
            "Total checks: %0d | Errors: %0d", checks, errors), UVM_NONE)
        if (errors == 0)
            `uvm_info("SCOREBOARD", "*** TODOS OS CHECKS PASSARAM ***", UVM_NONE)
        else
            `uvm_error("SCOREBOARD", $sformatf(
                "*** %0d ERROS DETECTADOS ***", errors))
    endfunction

endclass


// ======================================================
// COVERAGE
// ======================================================
class riscv_coverage extends uvm_component;

    `uvm_component_utils(riscv_coverage)

    uvm_analysis_imp #(riscv_transaction, riscv_coverage) analysis_export;

    bit [6:0] cov_opcode;
    bit [2:0] cov_funct3;
    bit [6:0] cov_funct7;
    bit [4:0] cov_rd;
    bit       cov_regWrite;
    bit       cov_memWrite;
  
  	riscv_transaction tr;

    covergroup riscv_cg;
      option.per_instance =1;
      option.at_least=1;
      cp_opcode: coverpoint tr.instruction[6:0] {
            bins rtype  = {7'b0110011};
            bins itype  = {7'b0010011};
            bins load   = {7'b0000011};
            bins store  = {7'b0100011};
            bins branch = {7'b1100011};
            bins jal    = {7'b1101111};
            bins jalr   = {7'b1100111};
            bins lui    = {7'b0110111};
            bins auipc  = {7'b0010111};
        }
      cp_funct3: coverpoint tr.instruction[14:12] {
            bins f3[] = {[3'b000 : 3'b111]};
        }
      cp_funct7: coverpoint tr.instruction[31:25] {
            bins normal = {7'b0000000};
            bins alt    = {7'b0100000};
            bins other  = default;
        }
        cp_rd: coverpoint tr.rd {
            bins zero     = {5'd0};
            bins low_regs = {[5'd1  : 5'd15]};
            bins hi_regs  = {[5'd16 : 5'd31]};
        }
        cp_regWrite: coverpoint tr.regWrite;
        cp_memWrite: coverpoint tr.memWrite;
        cx_op_f3: cross cp_opcode, cp_funct3;
        cx_rw_op: cross cp_regWrite, cp_opcode;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        riscv_cg        = new();
    endfunction

    //function void start_of_simulation_phase(uvm_phase phase);
    //    super.start_of_simulation_phase(phase);
    //    riscv_cg.start();
    //endfunction

  	function void write(riscv_transaction tr2);
    	$cast(tr, tr2.clone());
      	cov_opcode   = tr.instruction[6:0];
        cov_funct3   = tr.instruction[14:12];
        cov_funct7   = tr.instruction[31:25];
        cov_rd       = tr.rd;
        cov_regWrite = tr.regWrite;
        cov_memWrite = tr.memWrite;
        riscv_cg.sample();
    endfunction

    //function void report_phase(uvm_phase phase);
    //    super.report_phase(phase);
    //    `uvm_info("COVERAGE", $sformatf(
    //        "Cobertura funcional: %.2f%%", riscv_cg.get_coverage()), UVM_NONE)
    //endfunction

endclass


// ======================================================
// AGENT
// ======================================================
class riscv_agent extends uvm_agent;

    `uvm_component_utils(riscv_agent)

    riscv_driver                driver;
    uvm_sequencer #(riscv_item) sequencer;
    riscv_monitor               monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = riscv_driver::type_id::create("driver",    this);
        sequencer = uvm_sequencer #(riscv_item)::type_id::create("sequencer", this);
        monitor   = riscv_monitor::type_id::create("monitor",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass


// ======================================================
// ENV
// ======================================================
class riscv_env extends uvm_env;

    `uvm_component_utils(riscv_env)

    riscv_agent      agent;
    riscv_scoreboard scoreboard;
    riscv_coverage   coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = riscv_agent::type_id::create("agent",      this);
        scoreboard = riscv_scoreboard::type_id::create("scoreboard", this);
        coverage   = riscv_coverage::type_id::create("coverage",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.analysis_port.connect(scoreboard.analysis_export);
        agent.monitor.analysis_port.connect(coverage.analysis_export);
    endfunction

endclass


// ======================================================
// TEST
// ======================================================
class riscv_test extends uvm_test;

    `uvm_component_utils(riscv_test)

    riscv_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = riscv_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        riscv_base_sequence seq;
        phase.raise_objection(this);
        seq = riscv_base_sequence::type_id::create("seq");
        seq.num_transactions = 20;
        seq.start(env.agent.sequencer);
        #100;
        phase.drop_objection(this);
    endtask

endclass

endpackage
