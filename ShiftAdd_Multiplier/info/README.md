# Shift-Add Multiplier (Iterative) — FSM + Datapath + Counter

Multiplicador iterativo baseado no algoritmo **shift-and-add**, implementado em RTL (Verilog) com arquitetura clássica **Controller (FSM) + Datapath + Counter**. A cada iteração, o bloco verifica o LSB do registrador de produto e decide se soma o multiplicando na metade alta do acumulador antes de realizar o shift.

O projeto inclui:
- módulo top (`ShiftAdd_Multiplier.v`)
- FSM de controle (`FSM_ShiftAdd_Multiplier.v`)
- datapath com registrador `product` (`Datapath_ShiftAdd_Multiplier.v`)
- contador de iterações (`Counter_ShiftAdd_Multiplier.v`)
- testbench (`ShiftAdd_Multiplier_tb.v`)
- utilitário `log2_func.vh` para dimensionamento do contador

---

## Arquivos

- `ShiftAdd_Multiplier.v` — Top-level (instancia Counter/Datapath/FSM)
- `FSM_ShiftAdd_Multiplier.v` — FSM de controle (load/add/shift/done/ld_count)
- `Datapath_ShiftAdd_Multiplier.v` — Registrador `product` e operações (load/add/shift)
- `Counter_ShiftAdd_Multiplier.v` — Contador de iterações baseado em `log2(WIDTH)`
- `ShiftAdd_Multiplier_tb.v` — Testbench (gera `dump.vcd` e imprime resultado)
- `log2_func.vh` — Função `log2()` para cálculo de largura do contador

---

## Interface do Top

Módulo: `ShiftAdd_Multiplier #(parameter TOP_WIDTH=4)`

### Entradas
- `clk`: clock do sistema
- `rst`: reset assíncrono (ativo em 1)
- `multiplier[TOP_WIDTH-1:0]`: multiplicador
- `multiplicand[TOP_WIDTH-1:0]`: multiplicando
- `start`: inicia a operação (pulso)

### Saídas
- `product[(2*TOP_WIDTH):0]`: produto acumulado (largura **2*TOP_WIDTH + 1** bits)
- `done`: indica término da multiplicação (pulso)

> Observação: o `product` aqui é maior que o “usual” (2*WIDTH). Isso decorre do datapath somar com carry extra na metade alta (uso de `{1'b0, ...}`), mantendo 1 bit adicional.

---

## Algoritmo (visão RTL)

O datapath mantém um registrador `product` (acumulador + registrador de deslocamento). Fluxo típico:

1. **LOAD**:
   - carrega o `multiplier` em `product[WIDTH-1:0]`
   - zera o restante (por reset prévio ou inicialização)
2. Repetir por `WIDTH` iterações:
   - lê `lsb = product[0]`
   - se `lsb == 1`: soma `multiplicand` na metade alta do produto
   - realiza `shift right` em `product` (equivale a avançar a etapa do algoritmo)
3. Ao final, sinaliza `done`.

No seu design:
- a decisão de soma é tomada no estado `S1` lendo `lsb`
- o shift é realizado no estado `S2`
- o contador é incrementado via `ld_count`

---

## Microarquitetura

### Datapath (`Datapath_ShiftAdd_Multiplier.v`)
Registrador:
- `product[2*WIDTH:0]`

Operações controladas por sinais da FSM:
- `load`: `product[WIDTH-1:0] <= multiplier`
- `add`: soma `multiplicand` na parte alta do produto:
  - `product[2*WIDTH:WIDTH] = {1'b0, product[2*WIDTH-1:WIDTH]} + {1'b0, multiplicand}`
- `shift`: `product <= product >> 1`

Saída de decisão:
- `lsb = product[0]`

> Nota: `add` e `shift` são mutuamente exclusivos por controle da FSM.

### FSM (`FSM_ShiftAdd_Multiplier.v`)
Estados:
- `S0`: IDLE/LOAD sequencing
  - ao receber `start`, levanta `load`
  - após `load`, transita para `S1`
- `S1`: decisão por iteração
  - se `count < WIDTH`:
    - define `add = 1` se `lsb==1`, senão `add=0`
    - habilita `ld_count=1` e vai para `S2`
  - se `count >= WIDTH`: vai para `S3`
- `S2`: fase de `shift`
  - levanta `shift=1` e retorna a `S1`
- `S3`: done
  - levanta `done=1` e volta para `S0`

### Counter (`Counter_ShiftAdd_Multiplier.v`)
- Largura baseada em `COUNT_DEPTH = log2(WIDTH)`
- Incrementa `count` quando `ld_count=1`

---

## Testbench (`ShiftAdd_Multiplier_tb.v`)

- Gera `clk` com período de 10 ns
- Aplica reset e pulso de `start`
- Define:
  - `multiplier = 8'b1110_0011`
  - `multiplicand = 8'b1111_0010`
- Gera `dump.vcd`
- Imprime resultado no final

---

## Como simular (genérico)

Compile os arquivos na ordem (ajuste conforme seu simulador):
- `log2_func.vh`
- `Counter_ShiftAdd_Multiplier.v`
- `Datapath_ShiftAdd_Multiplier.v`
- `FSM_ShiftAdd_Multiplier.v`
- `ShiftAdd_Multiplier.v`
- `ShiftAdd_Multiplier_tb.v`

Ao rodar, o testbench gera:
- `dump.vcd`

---

## Notas / Melhorias possíveis (roadmap)
- Registrar `done` por 1 ciclo e travar o `product` até novo `start` (se necessário)
- Garantir reset/clear explícito do contador ao iniciar uma operação (hoje o contador só zera em `rst`)
- Revisar a ordem add/shift conforme especificação desejada (variações do algoritmo shift-add existem)
- Suporte a sinal (signed) e saturação/overflow (se entrar no escopo)
