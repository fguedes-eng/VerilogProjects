module Registers (
    input clk,
    input [4:0] rs1,        //read select
    input [4:0] rs2,
    input [4:0] ws,         //write select
    input [31:0] wd,        //write data
    input we,               //write enable
    output wire [31:0] rd1, //read data
    output wire [31:0] rd2
);

logic [31:0] rd_wr;
logic [31:0] reg_cell [0:31];

always @(posedge clk) begin
    if (we) begin
        reg_cell[ws] <= wd; 
    end
end 

assign rd1 = reg_cell[rs1];
assign rd2 = reg_cell[rs2];
endmodule