module SystemVerilogTest();


//tipos sintetizáveis:
wire w;
reg r;
//tipos de dados systemVerilog
//4 estados: 0, 1, x, z (Design)
logic l;
//2 estados: 0, 1 (Verificação)
int in;
bit b;
byte by;

//tipos não sintetizáveis:
integer i;
real re;
realtime rt;

//tipos singulares: representam um único valor
int, bit, logic (pode ser packed), string, ponteiros
//tipos agregados: representam uma coleção de valores
unpacked arrays, structs, unions

//sintetizabilidade depende da ferramenta/processo tecnológico
supply0 s0;
supply1 s1;
//Referente a charge strength: o quão rápido uma carga pode decair na net quando 
//não está driveada. "Capacitância" -> medium por padrão, pode ser large
trireg tr;
tri tr2;
//Referente a Drive strength: capacidade de ter prioridade no drive de uma net. A net vai
//tomar o valor do driver mais forte.
//strength1 = a força quando a net é driveada pra 1
//strength0 = a força quando a net é driveada pra 0
assign (strength1_or_0, strength1_or_0) net = expression;
//se for 1, vai ser um sinal strong. Se for 0, vai ser um sinal weak
assign (strong1, weak0) out = a & b;

//supply0 -> net sempre driveada pra 0, simulando GND
//supply1 -> net sempre driveada pra 1, simulando Vcc
//strong0 -> driver vai drivear net pra 0 com força
//strong1 -> driver vai drivear net pra 1 com força
//pull0 -> net tem um pull-down resistivo (vai ser driveada pra 0 se nenhum outro driver estiver driveando)
//pull1 -> net tem um pull-up resistivo
//weak0 -> driver vai drivear net pra 0 fracamente
//weak1 -> driver vai drivear net pra 1 fracamente
//highz0/1 -> net vai flutuar quando estiver em 0/1

//Design (síntese)
always_comb begin end
always_ff begin end
typedef enum data_type {  } name;

//Verificação (OOP)

//Assertions (SVA)
    //Linguagem de propriedades concorrentes dentro do SV para
    //especificar formalmente o comportamento do design ao longo do tempo

    //asserts imediatos: checa proceduralmente, uma vez por chama
    assert (A == B) -> Gera um erro se A for diferente de B.
    //Verificação com mensagem "tipo" if-else
    assert (A == B) $display ("OK. A equals B");
    else $error("It's gone wrong");

    //asserts concorrentes: assegura que a propriedade é sempre atendida
    assert property (!(Read && Write)); -> Gera erro se Read && Write forem true em qualquer ponto durante a simulação.
    |-> //operador de implicação, quando satisfeito um critério (lhs), checa uma expressão (rhs)
    |=> //mesma coisa, mas a expressão checada é checada após um ciclo de clock
    ##[min:max] //espera de min até max ciclos de clock a expressão consecutiva ser verdadeira, ## pode ser usado num clocking block ou em assertions
    //REPETIÇÕES
    [*rep] //repetição da expressão rep vezes, consecutivamente.
    [*rep:max] //repete a expressão de rep a max vezes, coconsecutivamente. Termina se a expressão for verdadeira entre rep e max vezes.
    [=N] //Expressão deve ocorrer N vezes, mas não precisa ser consecutivamente. Também, a expressão seguinte não precisa ocorrer no ciclo de clock imediato ao último sinal da expressão original.
    [->N] //Mesma coisa, mas a expressão seguinte DEVE ocorrer no ciclo de clock imediato ao último sinal da expressão original.
    ##[$] //pode repetir indefinidamente, checando a condição até ser atendida

    //properties: podem ser declaradas independentes dos asserts
    property not_read_and_write;
        not (Read && Write);
    endproperty assert property (not_read_and_write);

    //sequences: lhs e rhs das properties, podem ser declaradas separadamente também
    sequence request
        Req;
    endsequence

    sequence acknowledge
        ##[1:2] Ack;
    endsequence

    property handshake;
        @(posedge Clock) request |-> acknowledge;
    endproperty

    assert property (handshake);


/* TIPOS DE VERIFICAÇÃO */
-Verificação direcionada (Directed testing)
    -Abordagem clássica

-Verificação Restrita Aleatório (Constrained-Random Verificaion - CRV)
    -Muda o paradigma de "testar esse cenário específico" para "descrever o que é
    um cenário válido e deixar o simulador encontrar os cenários"
    -Cria-se uma classe (Packet) com propriedades (rand int length)
    -Define-se restrições
    -No teste, chama-se .randomize()

-Verificação Baseada em Assertions (SVA)
    -Permite escrever "propriedades" que monitoram o design concorrentemente
    -Exemplo: assert property (@(posedge clk) (req |-> ##[1:3] gnt));
    -Tradução: "Afirmo que, no posedge do clock, se req for verdadeiro, então gnt 
    deve se tornar verdadeiro entre 1 e 3 ciclos de clock depois"
    -O simulador avisa se a propriedade falhar

-Verificação Baseada em Cobertura (CDV)
    -Mede quais cenários funcionais foram atingidos
    -covergroup, coverpoint e cross
    -Termina quando cubriu todos os coverpoints

/* CLASSES */

//casting
x = tipo'(y)

//param
parameter - configurável e sobrescrevível
localparam - não pode ser sobrescrita
specparam - usado em blocos specify
const - constante

//classes
class className;
    //dados
    bit a;
    bit b;

    //construtor, feito automaticamente se não explicitado
    function new();
        a = 1'b0;
        b = 1'b1;
    endfunction //new()

    //métodos
    task taskName(arguments);

    endtask
    //tasks não precisam retornar nada, functions são obrigados a retornar valor, e só podem
    //drivear um output, e não podem conter delay.
    function integer func();
        func = a + b;
        //ou return a + b
    endfunction
endclass //className

className C; //cria uma variável do tipo da classe
C = new(); //cria um objeto da classe e atribui a C, C armazena um handle do objeto inicializado
C.a = 1'b0;

//Caso tiver um enum na classe, pode ser acessada de duas formas:
//className::ERROR
//C.ERROR
//tem this pra referência própria
//assignment -> copia a referência do objeto pra outra variável
//renaming -> atribui um objeto a uma nova variável com nome diferente.
//copying -> cria uma nova instância com um novo objeto com o mesmo estado de um objeto já existente

//suporte a herança
class Cachorro extends Animal;

endclass

//suporte a polimorfismo (sobrescrever métodos da classe pai)
//super refere-se à classe pai
//encapsulamento:
local /**(private)**/, public, protected

//métodos virtuais são construção polimórfica básica
    virtual function int func(); -> classe base pode implementar, classes derivadas podem sobrescrever
    pure virtual function int func(); -> obriga classe derivada a implementar


/* CONTROLE DE TEMPO */
wait (expression) -> espera expression ser true
@ event_expression -> suspende a execução até que ocorra o evento
@(expresssion)
@(posedge expression)
@(negedge expression)
@(edge expression)

repeat (expression) -> repete um número de vezes

fork
    ->comandos executam ao mesmo tempo. Bloco só termina quando último comando for concluído
join

/* CLOCKING BLOCKS */

//Se faz necessário como regra de timing. Sem ele, pode haver problemas entre o tb e o DUT de race condition.
//Ex: TB e DUT têm um always @(posedge clk) com o mesmo clock. Um tenta ler e o outro tenta escrever no mesmo tempo. Race condition.
//inputs são inputs PARA O TB, não para o DUT, outputs idem
clocking bus @(posedge clock1);
    default input #10ns output #2ns;
    input data, ready, enable = top.mem1.enable;
    output negedge ack;
    input #1step addr;
endclocking

//uso:
##1 //um ciclo de clk
bus.data <= drive;
@(bus) //a cada ciclo de bus
bus.ready <= n_sei_oq;
bus.enable //criado como alias no lugar de bus.top.mem1.enable

/* INTERFACES */
Usado como um encapsulamento de vários ports pra modularizar e reduzir a declaração da lista de ports dos modulos

interface simple_bus
    logic req, gnt;
    logic [7:0] addr, data;
    logic [1:0] mode;
    logic start, rdy;
endinterface: simple_bus

module memMod (simple_bus a, input logic clk);
...
a.req = ....
a.addr = ...
endmodule

module top_tb();
    logic clk = 0;
    simple_bus sb_if(); //instancia a interface

    memMod mem(sb_inf, clk); //instancia o DUT e coloca a interface nele
endmodule

modport serve pra informar direção de input ou output para módulos que vão utilizar uma mesma interface

criam-se modports diferentes para cada módulo informando como aquele
módulo vai enxergar os sinais da interface em relação a input/output

Exemplo:
interface i2;
    wire a, b, c, d;
    modport master (input a, b, output c, d); //master enxerga a b como input e c d como output
    modport slave (output a, b, input c, d); //slave enxerga a b como output e c d como input
endinterface

isso serve pra ferramenta poder verificar se o sinal chegando da interface é input ou output

modport expressions servem pra permitir ao modport criar um elemento personalizado com .nome(expressao_personalizada)

Exemplo:

interface i
    logic [7:0] r;
    const int x = 1;
    bit R;
    modport A (output .P(r[3:0]), input .Q(x), R);
    modport B (output .P(r[7:4]), input .Q(2), R);
endinterface

module M (interface i);
    initial i.P = i.Q; //se for um modport A, r[3:0] = 1'b1, se for B, r[7:4] = 2'b10
endmodule

module top;
    I i1 (); //instancia interface
    M u1 (i1.A); //instancia DUT M que recebe interface com modport A
    //i1.r[3:0] = 1'b1, logo i1.r = xxxx_0001
    M u2 (i1.B); //instancia DUT M que recebe interface com modport B
    //i1.r[7:4] = 1'b10, logo i1.r = 0010_xxxx
    initial #1 $display("%b", i1.r) //i1.r = 0010_0001
endmodule



endmodule
