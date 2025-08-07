// Code your design here
module Blackjack (
  input clk,
  input reset,
  input stay,
  input hit,
  input [4 - 1:0] random,
  output win,
  output lose,
  output tie,
  //output tb
  output wire wfirst_draw,
  output wire wsoma_terminada,
  output wire [2:0] wcurrent_state,
  output wire whit_reg,
  output wire [2:0] wnext_state,
  output wire [4 - 1:0] wdeck [52],
  output wire [1:0] wdraw,
  output wire [3:0] wcard,
  output wire [6:0] wdeck_pos,
  output wire [3:0] whand [11],
  output wire wplayer_or_dealer,
  output wire [5:0] wreg_soma [11],
  output wire whit_reg_press,
  output wire [5:0] wsoma,
  output wire [5:0] wsoma_dealer
);

/************\
|*Constantes*|
\************/

// número de cartas = 13 -> 4 bits
parameter CARD = 4;
//soma máxima = 30 -> 6 bits
parameter MAX_SUM = 6;

reg win_reg, lose_reg, tie_reg;

reg [2:0] current_state;
reg [2:0] next_state;
wire [MAX_SUM - 1:0] soma;
wire [MAX_SUM - 1:0] soma_dealer;
reg [MAX_SUM - 1:0] reg_soma [11];
reg [MAX_SUM - 1:0] reg_soma_dealer [11];
reg [CARD - 1:0] deck [52];
reg [CARD - 1:0] card;
reg [CARD - 1:0] out_hand_temp [11];

/* Pior caso: A A A A 2 2 2 2 3 3 X = 11 cartas */
reg [CARD - 1:0] hand [11];
reg [CARD - 1:0] hand_dealer [11];
integer hand_pos;
reg [1:0] draw;
reg first_draw;// = 1;
reg soma_terminada;// = 0;
reg player_or_dealer;

reg hit_reg;
reg hit_reg_press;
reg first_cards_completed;
reg drawing_cards;
reg stop_dealing;

reg [CARD - 1:0] valor;
wire[CARD - 1:0] out_hand [11];
wire[CARD - 1:0] out_hand_dealer [11];

integer i;
integer deck_pos;
integer out_hand_pos;

//estados
parameter [2:0] INICIO        = 3'b000;
parameter [2:0] FIRST_CARDS   = 3'b001;
parameter [2:0] HIT_CARD      = 3'b010;
parameter [2:0] DEALER_CARDS  = 3'b011;
parameter [2:0] FINALIZACAO   = 3'b100;

/* Cartas */
/* Aqui as cartas ainda não estão sendo atribuídas valor, mas uma identidade única */
/* Dessa forma, o jogo é capaz de informar ao player que carta ele tirou, e utilizar um decodificador pra saber qual valor a carta possui */
parameter [3:0] AS        = 4'b0001;
parameter [3:0] DOIS      = 4'b0010;
parameter [3:0] TRES      = 4'b0011;
parameter [3:0] QUATRO    = 4'b0100;
parameter [3:0] CINCO     = 4'b0101;
parameter [3:0] SEIS      = 4'b0110;
parameter [3:0] SETE      = 4'b0111;
parameter [3:0] OITO      = 4'b1000;
parameter [3:0] NOVE      = 4'b1001;
parameter [3:0] DEZ       = 4'b1010;
parameter [3:0] VALETE    = 4'b1011;
parameter [3:0] DAMA      = 4'b1100;
parameter [3:0] REI       = 4'b1101;


parameter PLAYER = 0;
parameter DEALER = 1;

/* Preenchimento de memória com as cartas */


always @(card) begin
  if (player_or_dealer === PLAYER) begin
    hand[hand_pos] = card;
  end else if (player_or_dealer === DEALER) begin
    hand_dealer[hand_pos] = card;
  end
  hand_pos = hand_pos + 1;
end


/* Retira a carta da memória */
always @(posedge clk) begin
  if (reset) begin
    first_draw <= 1;
    soma_terminada <= 0;
    hit_reg <= 0;
    hand_pos <= 0;
    drawing_cards <= 0;

    deck_pos = random;
    next_state = INICIO;
    for (i = 0; i < 52; i = i + 1) begin
      deck[i] = i % 13 + 1;
    end
  end
  if (current_state === FIRST_CARDS && first_draw) begin
    draw <= 2;
    first_draw <= 0;
  end
  else if (current_state === HIT_CARD && hit_reg === 1) begin
    draw <= 1;
  end
  else if (current_state == DEALER_CARDS ) begin
    draw <= draw + 1;
  end

  if (draw && !stop_dealing) begin
    drawing_cards <= 1;
    deck_pos <= random;
    /* Procura uma posição do deck com carta */
    if (deck[deck_pos] !== 0) begin
      /* Pega carta do deck*/
      card <= deck[deck_pos];
      /* Retira o valor da carta do deck */
      deck[deck_pos] <= 4'b0000;
      /* Diminui o contador de quantas cartas pegar de uma vez */
      draw <= draw - 1;
    end
  end
  else if (drawing_cards === 1 && draw === 0) begin
    drawing_cards <= 0;
    first_cards_completed <= 1;
  end
end

/* Decodificador + load registrador soma */
always @(*) begin

  if (player_or_dealer === PLAYER) begin
    for (i = 0; i < 12; i = i + 1) begin
      out_hand_temp[i] = hand[i];
    end
  end else if (player_or_dealer === DEALER) begin
    for (i = 0; i < 12; i = i + 1) begin
      out_hand_temp[i] = hand_dealer[i];
    end
  end

  for (out_hand_pos = 0; out_hand_pos < 11; out_hand_pos = out_hand_pos + 1) begin
    case (out_hand_temp[out_hand_pos])
      AS:     valor = 1;
      DOIS:   valor = 2;
      TRES:   valor = 3;
      QUATRO: valor = 4;
      CINCO:  valor = 5;
      SEIS:   valor = 6;
      SETE:   valor = 7;
      OITO:   valor = 8;
      NOVE:   valor = 9;
      DEZ:    valor = 10;
      VALETE: valor = 10;
      DAMA:   valor = 10;
      REI:    valor = 10;
      default: valor = 0;
    endcase
    if (player_or_dealer == PLAYER) begin
      reg_soma[out_hand_pos] = valor;
    end else if (player_or_dealer == DEALER) begin
      reg_soma_dealer[out_hand_pos] = valor;
    end
  end
end

/* Somador */
/*always @(stay or hit) begin
integer reg_soma_pos;
for (reg_soma_pos = 0; reg_soma_pos < 11; reg_soma_pos = reg_soma_pos + 1) begin
if (player_or_dealer === PLAYER) begin
soma = soma + reg_soma[reg_soma_pos];
end else if (player_or_dealer === DEALER) begin
soma_dealer = soma_dealer + reg_soma[reg_soma_pos];
end
soma_terminada = 1;
end
end*/

/* Atualização máquina de estados */
always @(posedge clk) begin
  current_state <= next_state;
end

/* controle do hit para durar um ciclo de clock */
always @(posedge clk) begin
  if (hit === 1 && hit_reg_press === 1) begin
    hit_reg <= 1;
    hit_reg_press <= 0;
  end
  else if (hit === 1 && hit_reg_press === 0) begin
    hit_reg <= 0;
  end
  else if (hit == 0) begin
    hit_reg <= 0;
    hit_reg_press <= 1;
  end
end


/* Máquina de estados */
always @(*) begin
  case (current_state)
    INICIO:	begin
      stop_dealing = 0;
      if (hit_reg) begin
        next_state = FIRST_CARDS;
      end
    end

    FIRST_CARDS:	begin
      player_or_dealer = PLAYER;
      if (first_cards_completed) begin
        next_state = HIT_CARD;
      end
    end

    HIT_CARD:	begin
      player_or_dealer = PLAYER;

      if (stay == 1 || soma == 21) begin
        hand_pos = 0;
        next_state = DEALER_CARDS;
      end

      if (soma > 21) begin
        stop_dealing = 1;
        hand_pos = 0;
        next_state = FINALIZACAO;
      end
    end

    DEALER_CARDS:	begin
      stop_dealing = 0;
      player_or_dealer = DEALER;   
      if (soma_dealer >= 17) begin
        stop_dealing = 1;
        next_state = FINALIZACAO;
      end
    end

    FINALIZACAO:	begin
      //comparar as duas somas
      if (soma > 21) begin
        //perdeu
        win_reg = 0;
        tie_reg = 0;
        lose_reg = 1;
      end
      else if (soma == soma_dealer) begin
        //empate
        win_reg = 0;
        tie_reg = 1;
        lose_reg = 0;
      end
      else if (soma > soma_dealer) begin
        //ganhou
        win_reg = 1;
        tie_reg = 0;
        lose_reg = 0;
      end
      else if (soma_dealer > 21) begin
        win_reg = 1;
        tie_reg = 0;
        lose_reg = 0;
      end
      else if (soma < soma_dealer) begin
        //perdeu
        win_reg = 0;
        tie_reg = 0;
        lose_reg = 1;
      end
      //display pro usuário
      //reset
    end

    default:
      next_state = INICIO;
  endcase
end

assign win = win_reg;
assign lose = lose_reg;
assign tie = tie_reg;
assign soma = reg_soma[0] + reg_soma[1] + reg_soma[2] + reg_soma[3] + reg_soma[4] + reg_soma[5] + reg_soma[6] + reg_soma[7] + reg_soma[8] + reg_soma[9] + reg_soma[10]; 
assign soma_dealer = reg_soma_dealer[0] + reg_soma_dealer[1] + reg_soma_dealer[2] + reg_soma_dealer[3] + reg_soma_dealer[4] + reg_soma_dealer[5] + reg_soma_dealer[6] + reg_soma_dealer[7] + reg_soma_dealer[8] + reg_soma_dealer[9] + reg_soma_dealer[10];
/*testbench wires*/
assign wfirst_draw = first_draw;
assign wsoma_terminada = soma_terminada;
assign wcurrent_state = current_state;
assign whit_reg = hit_reg;
assign wnext_state = next_state;
assign wdeck = deck;
assign wplayer_or_dealer = player_or_dealer;

assign wdraw = draw;
assign wcard = card;  
assign wdeck_pos = deck_pos;
assign whand = hand;
assign wreg_soma = reg_soma;
assign whit_reg_press = hit_reg_press;
assign wsoma = soma;
assign wsoma_dealer = soma_dealer;

endmodule
