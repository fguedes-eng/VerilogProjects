`ifndef UTILS_VH
`define UTILS_VH

// --------------------------------------------------------------------
// Função log2
// Retorna o número de bits necessários para representar um valor.
// Exemplo:
//   log2(16) = 4
//   log2(17) = 5
// --------------------------------------------------------------------
function integer log2;
    input integer value;
    integer tmp;
    begin
        tmp = value - 1;
        log2 = 0;
        while (tmp > 0) begin
            log2 = log2 + 1;
            tmp = tmp >> 1;
        end
    end
endfunction

`endif