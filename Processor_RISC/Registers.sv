module Registers (
    input clk,
    input rst,
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

genvar i;
generate
for (i = 0; i < 32; i++) begin : dump
    initial $dumpvars(0, reg_cell[i]);
end
endgenerate

always @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i;
        for (i = 1; i < 32; i = i + 1) begin
            reg_cell[i] <= 0;
        end
    end else begin
        if (we && ws != 0) begin
            reg_cell[ws] <= wd;
        end
    end
end

assign rd1 = (rs1 == 0) ? 32'b0 : reg_cell[rs1];
assign rd2 = (rs2 == 0) ? 32'b0 : reg_cell[rs2];

endmodule
