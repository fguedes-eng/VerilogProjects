# UART (TX/RX) + FIFO (4-deep) + Parity + Baud Selector

Implementação de UART em RTL (Verilog) com transmissão e recepção, bit de paridade (par/ímpar), e buffering de transmissão via FIFO interna de 4 posições. O projeto inclui um top-level (`UART.v`) com integração completa e um testbench funcional (`UART_tb.v`) para simulação por waveform (VCD).

> Clock base assumido: **50 MHz** (gerador de baud interno).

---

## Visão geral da arquitetura

O IP é composto por:

- **Baud generator (`Baud_Rate`)**: gera `BaudRate` selecionável (9600/19200/38400/57600).
- **Parity (`UART_Parity`)**: calcula paridade par/ímpar para o byte de entrada.
- **TX (`UART_Tx`)**:
  - FSM de transmissão UART (start → 8 bits → parity → stop)
  - FIFO interna **4-deep** para enfileirar bytes a transmitir
- **RX (`UART_Rx`)**:
  - FSM de recepção UART (start → 8 bits → parity check → stop check → ready)
  - Flags: `ParityError`, `StopBitError`
- **Register/control (`UART_Reg_cntrl`)**:
  - sincroniza `In_rdy` e detecta borda
  - gera `FIFO_send` (push no FIFO TX) e `Send_TX` (habilita TX quando não busy)
  - gera flag `Overflow` quando tenta enfileirar e FIFO está cheia
- **Output latch (`UART_Reg_FPGA`)**:
  - registra `Data_Out` em `Data_Out_FPGA` quando `Out_rdy` está ativo

---

## Arquivo top-level: `UART.v`

### Entradas
- `clk`: clock base (50 MHz)
- `rst`: reset assíncrono
- `Data_In[7:0]`: byte a transmitir
- `In_rdy`: pulso/nível indicando que `Data_In` está válido para envio
- `baud_select[1:0]`: seleção do baud rate
- `parity_sel`: 0 = par, 1 = ímpar
- `Rx`: entrada serial do receptor

### Saídas
- `Tx`: saída serial do transmissor
- `Data_Out[7:0]`: byte recebido (saída direta do RX)
- `Out_rdy`: indica que `Data_Out` está válido (pulso)
- `Data_Out_FPGA[7:0]`: versão registrada de `Data_Out` (latch em `Out_rdy`)
- `Overflow`: tentativa de push com FIFO cheia
- `Parity`: bit de paridade calculado para `Data_In`
- `ParityError`: erro de paridade detectado no RX
- `StopBitError`: erro de stop bit detectado no RX

---

## Baud rate generator: `UART_Baud_rate_gen.v`

Módulo `Baud_Rate` gera um sinal `BaudRate` (onda quadrada) com base em `baud_sel`. O projeto assume `clk = 50 MHz`.

Baud rates suportados:
- `00`: 9600
- `01`: 19200
- `10`: 38400
- `11`: 57600

> Nota de integração: este design utiliza `BaudRate` como clock de operação para TX/RX/controle (clock derivado).

---

## TX: `UART_Tx.v` (FSM + FIFO 4-deep)

### FIFO interna
- Profundidade: **4 entries**
- Implementada como array `FIFO[0:3]`
- Ponteiros:
  - `wr_ptr` e `rd_ptr` (mod 4 via `& 3`)
- Flag:
  - `FIFO_full`

### FSM de transmissão
Estados:
- `S0`: IDLE (aguarda dados no FIFO)
- `S1`: START bit (Tx=0)
- `S2`: envia 8 bits (`TxBuffer[counter]`)
- `S3`: envia paridade (`Tx=Parity`)
- `S4`: envia stop bit (`Tx=1`)

Sinais relevantes:
- `Send_TX`: habilita TX se `Tx_Busy==0`
- `FIFO_send`: push do `Data_In` no FIFO

> Observação: o TX atual envia `Parity` calculado diretamente de `Data_In`. Se houver enfileiramento de múltiplos bytes, uma evolução natural é armazenar paridade junto do byte enfileirado (para garantir paridade correta por-entry).

---

## RX: `UART_Rx.v` (FSM + parity/stop checks)

Estados:
- `S0`: espera start bit (`Rx==0`)
- `S1`: captura 8 bits em `Data_Out[counter]`
- `S2`: lê bit de paridade e compara com paridade esperada
- `S3`: checa stop bit (espera `Rx==1`)
- `S4`: sinaliza `Out_rdy=1` e retorna ao IDLE

Flags:
- `ParityError`: setado quando a paridade recebida não bate com o esperado (par/ímpar)
- `StopBitError`: setado quando stop bit inválido

---

## Controle de envio: `UART_Reg_controller.v`

- Sincroniza `In_rdy` (2 FFs) e detecta borda de subida (`In_rdy_edge`)
- Se `In_rdy_edge` e `!FIFO_full` → gera `FIFO_send=1`
- Se `In_rdy_edge` e `FIFO_full` → gera `Overflow=1`
- `Send_TX = !Tx_Busy`

---

## Output register: `UART_Reg_FPGA.v`

Registra `Data_Out` em `Data_Out_FPGA` quando `Out_rdy` está ativo.

---

## Testbench: `UART_tb.v`

- Gera clock `clk` de 50 MHz (`#10` ns half-period)
- Seleciona baud (`baud_select`)
- Aplica sequência de bytes em `Data_In` com pulso `In_rdy`
- Dump de waveform:
  - `dump.vcd`

Exemplos de estímulos:
- 0x57 (caso normal)
- 0x00, 0x11, 0x22, ... (casos de borda)

> Nota: o TB conecta `Rx` ao próprio `Tx` (`.Rx(Tx)`), formando loopback para validar TX->RX.

---

## Como simular (exemplo genérico)

1) Compile (ajuste a lista de arquivos):
- `UART.v`, `UART_Tx.v`, `UART_Rx.v`, `UART_Parity.v`, `UART_Reg_controller.v`, `UART_Reg_FPGA.v`, `UART_Baud_rate_gen.v`, `UART_tb.v`

2) Rode e abra o VCD:
- Verifique `Tx`, `Rx`, `Out_rdy`, `Data_Out`, `ParityError`, `StopBitError`.

---

## Pontos de melhoria / roadmap (intencional)

- **Oversampling no RX** (8x/16x) e amostragem no centro do bit (maior robustez)
- Evitar clocks derivados: trocar `BaudRate` por **baud_tick enable**
- Armazenar paridade por-entry na FIFO TX (byte+paridade)
- FIFO RX (opcional) para buffering de recebidos
- Parâmetros para stop bits e largura de data
