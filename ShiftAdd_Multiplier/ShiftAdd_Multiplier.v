`include "log2_func.vh"

module ShiftAdd_Multiplier #(parameter TOP_WIDTH = 4) (
    input clk,
    input rst,
    input [TOP_WIDTH - 1:0] multiplier,
    input [TOP_WIDTH - 1:0] multiplicand,
    input start,
    output [TOP_WIDTH * 2:0] product,
    output done
);

localparam COUNT_DEPTH = log2(TOP_WIDTH); 

reg shift;
reg [COUNT_DEPTH:0] count;
reg load;
reg add;
reg lsb;
reg ld_count;

Counter_ShiftAdd_Multiplier #(.WIDTH(TOP_WIDTH)) Counter(.clk(clk), .rst(rst), .ld_count(ld_count), .count(count)); 
DataPath_ShiftAdd_Multiplier #(.WIDTH(TOP_WIDTH)) Datapath(.clk(clk), .rst(rst), .multiplier(multiplier), .multiplicand(multiplicand), .load(load), .shift(shift), .add(add), .lsb(lsb), .product(product));
FSM_ShiftAdd_Multiplier #(.WIDTH(TOP_WIDTH)) Controller(.clk(clk), .rst(rst), .start(start), .lsb(lsb), .count(count), .load(load), .shift(shift), .add(add), .done(done), .ld_count(ld_count));
    

endmodule