// ======================================================
// ASSERTIONS — riscv_assertions.sv
// ======================================================
module riscv_assertions (
    input logic        clk,
    input logic        rst,
    input logic [31:0] pc,
    input logic [31:0] pc_in,
    input logic        regWrite,
    input logic [4:0]  rd,
    input logic [31:0] wb_in,
    input logic [1:0]  PCSel
);

    // --------------------------------------------------
    // Contador de estabilização pós-reset
    // Necessário porque:
    //  (a) sinais combinacionais saem de X após 1 ciclo
    //  (b) $past() no 1º ciclo retorna valores de reset
    //  (c) o DUT pode ter latência interna de 1 ciclo
    // --------------------------------------------------
    int unsigned cycles_after_rst;

    always_ff @(posedge clk) begin
        if (rst)
            cycles_after_rst <= 0;
        else if (cycles_after_rst < 2)
            cycles_after_rst <= cycles_after_rst + 1;
    end

    wire stable = (cycles_after_rst >= 1);

    // --------------------------------------------------
    // P1: PC alinhado em 4 bytes
    // --------------------------------------------------
    property p_pc_aligned;
        @(posedge clk) disable iff (rst || !stable)
        pc[1:0] == 2'b00;
    endproperty

    ap_pc_aligned: assert property (p_pc_aligned)
        else `uvm_error("ASSERT", $sformatf("PC desalinhado: pc=%0h", pc))

    // --------------------------------------------------
    // P2: PC+4 em modo sequencial
    //
    // Guarda $past(stable) exigida porque:
    //  - No 1º ciclo estável, $past(PCSel) ainda vem
    //    do período de reset onde PCSel==0, ativando
    //    o antecedente com pc_anterior inválido.
    // --------------------------------------------------
    property p_pc_plus4;
        @(posedge clk) disable iff (rst || !stable)
        ($past(stable) && $past(PCSel) == 2'b00) |->
            (pc == $past(pc) + 4);
    endproperty

    ap_pc_plus4: assert property (p_pc_plus4)
        else `uvm_error("ASSERT", $sformatf(
            "Erro PC+4: era=%0h esperado=%0h obtido=%0h",
            $past(pc), $past(pc)+4, pc))

    // --------------------------------------------------
    // P3: Sem escrita efetiva em x0
    //
    // O Registers.sv protege x0 com: if (we && ws != 0).
    // A Control_unit pode setar regWrite=1 com rd=0 para
    // instruções cujo encoding coloca x0 em [11:7].
    // A assertion útil aqui é: se rd=0, o wb_data não
    // importa (Registers ignora), mas regWrite=1 com rd=0
    // para NOPs ou instruções legítimas não é uma violação.
    //
    // Mantemos a assertion como aviso informativo (UVM_WARNING)
    // pois pode indicar opcodes não reconhecidos com latching
    // de regWrite=1 do ciclo anterior.
    // --------------------------------------------------
    property p_no_write_x0;
        @(posedge clk) disable iff (rst || !stable)
        (regWrite === 1'b1 && rd == 5'd0) |-> 1'b0;
    endproperty

    ap_no_write_x0: assert property (p_no_write_x0)
        else `uvm_warning("ASSERT",
            $sformatf("regWrite=1 com rd=x0 (Registers protege x0): rd=%0d regWrite=%b [info only]",
                      rd, regWrite))

    // --------------------------------------------------
    // P4: wb_in sem X/Z quando regWrite ativo
    // --------------------------------------------------
    property p_wb_no_x;
        @(posedge clk) disable iff (rst || !stable)
        (regWrite === 1'b1) |-> !$isunknown(wb_in);
    endproperty

    ap_alu_no_x: assert property (p_wb_no_x)
        else `uvm_error("ASSERT",
            $sformatf("wb_in=X/Z com regWrite ativo: wb_in=%0h rd=x%0d",
                      wb_in, rd))

    // --------------------------------------------------
    // P5: Incremento de PC exatamente +4 em modo sequencial
    // --------------------------------------------------
    property p_pc_increment_sane;
        @(posedge clk) disable iff (rst || !stable)
        ($past(stable) && $past(PCSel) == 2'b00) |->
            ((pc - $past(pc)) == 32'd4);
    endproperty

    ap_pc_sane: assert property (p_pc_increment_sane)
        else `uvm_error("ASSERT", $sformatf(
            "Incremento de PC anormal: delta=%0d pc=%0h past_pc=%0h",
            (pc - $past(pc)), pc, $past(pc)))

endmodule