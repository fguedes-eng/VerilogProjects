# Processador RISC-V Single-Cycle 32 bits

Este é um processador de 32 bits capaz de executar todas as instruções básicas definidas pelo **ISA do RISC-V**.

---

## Estrutura do Projeto

O processador é composto pelos seguintes módulos principais:

- **ALU (Unidade Lógico-Aritmética)** — `ALU.sv`  
- **Banco de Registradores** — `Registers.sv` (32 registradores de 32 bits)  
- **Memória de Dados** — `Data_memory.sv`  
- **Memória de Instruções** — `Instruction_memory.sv`  
- **Decodificador de Instruções** — `Instruction_decoder.sv`  
- **Contador de Programa (PC)** — `Program_Counter.sv`  
- **Unidade de Controle** — `Control_unit.sv`  

O arquivo `Multiplexers.sv` implementa a lógica dos multiplexadores responsáveis pela seleção de dados do **datapath** para o **PC**, **Write Back (WB)** e entradas da **ALU**.  
O controle de seleção desses sinais, bem como de todos os demais componentes, é realizado pela **unidade de controle**.

O pacote `AA_mnemonics_pkg.sv` define constantes nomeadas que facilitam a leitura e o entendimento do código, sendo compartilhadas entre os módulos.

---

## Testbench

O projeto inclui um **testbench** que executa um programa simples, equivalente ao código C abaixo:

```c
const char Hello[] = "Hello World!";
const char Bye[] = "Bye World!";

int x5 = 1; // valor
int x6 = 1; // valor2

if (x5 == x6) {
    printf("%s", Hello);
} else {
    printf("%s", Bye);
}
```
---

## Próximos Passos

1. Adicionar pipeline  
2. Implementar operações de ponto flutuante  
3. Adicionar novas instruções  
4. Tornar os bits parametrizáveis
5. Incluir suporte a instruções vetoriais