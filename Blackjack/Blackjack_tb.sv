// Code your testbench here
// or browse Examples

module Blackjack_tb ();
  reg clk_tb;
  reg reset_tb;
  reg stay_tb;
  reg hit_tb;
  wire win_tb;
  wire lose_tb;
  wire tie_tb;
  //output tb
  wire wfirst_draw_tb;
  wire wsoma_terminada_tb;
  wire [2:0] wcurrent_state_tb;
  wire whit_reg_tb;
  wire [2:0] wnext_state_tb;
  wire [4 - 1:0] wdeck_tb [52];
  wire [1:0] wdraw_tb;
  wire [3:0] wcard_tb;
  wire [6:0] wdeck_pos_tb;
  wire [3:0] whand_tb [11];
  wire wplayer_or_dealer_tb;
  wire [5:0] wreg_soma_tb [11];
  wire whit_reg_press_tb;
  wire [5:0] wsoma_tb;
  wire [5:0] wsoma_dealer_tb;
  
  integer i;
  int unsigned seed;

  Blackjack DUT(clk_tb, reset_tb, stay_tb, hit_tb, win_tb, lose_tb, tie_tb, wfirst_draw_tb, wsoma_terminada_tb, wcurrent_state_tb, whit_reg_tb, wnext_state_tb, wdeck_tb, wdraw_tb, wcard_tb, wdeck_pos_tb, whand_tb, wplayer_or_dealer_tb, wreg_soma_tb, whit_reg_press_tb, wsoma_tb, wsoma_dealer_tb);
  
  initial begin
    clk_tb = 0;
    forever #3 clk_tb = ~clk_tb;
  end
  
  initial begin
    seed = 121;
    $urandom(seed);
    $dumpfile("dump.vcd");
    $dumpvars(0, Blackjack_tb);
    $monitor("at time %4t: current_state = %b, reset = %b, hit = %b, hit_reg = %b, next_state = %b, draw = %b, card = %b, deck_pos = %b, player_or_dealer = %b, hit_reg_press = %b, soma = %d, soma_dealer = %d, win = %b, lose = %b, tie = %b", $realtime, wcurrent_state_tb, reset_tb, hit_tb, whit_reg_tb, wnext_state_tb, wdraw_tb, wcard_tb, wdeck_pos_tb, wplayer_or_dealer_tb, whit_reg_press_tb, wsoma_tb, wsoma_dealer_tb, win_tb, lose_tb, tie_tb);
    hit_tb = 0;
    reset_tb = 0; #10;
    reset_tb = 1; #10;
    reset_tb = 0; #10;
    for (i = 0; i < 52; i = i + 1) begin
      $display ("deck: %b", wdeck_tb[i]);
    end
    hit_tb = 1; #100;
    hit_tb = 0; #10;
    #10;
    hit_tb = 1; #100;
    hit_tb = 0; #10;
    #10;
    stay_tb = 1;
    #100;
    for (i = 0; i < 11; i = i + 1) begin
      $display("hand: %b", whand_tb[i]);
    end
    for (i = 0; i < 11; i = i + 1) begin
      $display("reg_soma: %b", wreg_soma_tb[i]);
    end
    $stop;
  end
  
  
  
endmodule