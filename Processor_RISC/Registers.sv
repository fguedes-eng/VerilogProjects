module Registers (
    input clk,
    input rst,
    input [4:0] rs1,        //read select
    input [4:0] rs2,
    input [4:0] ws,         //write select
    input [31:0] wd,        //write data
    input we,               //write enable
    input [1:0] wb_ctrl,
    output wire [31:0] rd1, //read data
    output wire [31:0] rd2,
    /* Output debug */
    output wire [31:0] x7,
    output wire [31:0] x8,
    output wire [31:0] x9
);

localparam WB_IMM = 2'b10;

logic [31:0] rd_wr;
logic [31:0] reg_cell [0:31];

logic [31:0] reg_cell_debug_0;
logic [31:0] reg_cell_debug_1;
logic [31:0] reg_cell_debug_2;
logic [31:0] reg_cell_debug_3;
logic [31:0] reg_cell_debug_4;
logic [31:0] reg_cell_debug_5;
logic [31:0] reg_cell_debug_6;
logic [31:0] reg_cell_debug_7;
logic [31:0] reg_cell_debug_8;
logic [31:0] reg_cell_debug_9;
logic [31:0] reg_cell_debug_10;
logic [31:0] reg_cell_debug_11;
logic [31:0] reg_cell_debug_12;
logic [31:0] reg_cell_debug_13;
logic [31:0] reg_cell_debug_14;
logic [31:0] reg_cell_debug_15;
logic [31:0] reg_cell_debug_16;
logic [31:0] reg_cell_debug_17;
logic [31:0] reg_cell_debug_18;
logic [31:0] reg_cell_debug_19;
logic [31:0] reg_cell_debug_20;
logic [31:0] reg_cell_debug_21;
logic [31:0] reg_cell_debug_22;
logic [31:0] reg_cell_debug_23;
logic [31:0] reg_cell_debug_24;
logic [31:0] reg_cell_debug_25;
logic [31:0] reg_cell_debug_26;
logic [31:0] reg_cell_debug_27;
logic [31:0] reg_cell_debug_28;
logic [31:0] reg_cell_debug_29;
logic [31:0] reg_cell_debug_30;
logic [31:0] reg_cell_debug_31;


assign reg_cell_debug_0 = reg_cell[0];
assign reg_cell_debug_1 = reg_cell[1];
assign reg_cell_debug_2 = reg_cell[2];
assign reg_cell_debug_3 = reg_cell[3];
assign reg_cell_debug_4 = reg_cell[4];
assign reg_cell_debug_5 = reg_cell[5];
assign reg_cell_debug_6 = reg_cell[6];
assign reg_cell_debug_7 = reg_cell[7];
assign reg_cell_debug_8 = reg_cell[8];
assign reg_cell_debug_9 = reg_cell[9];
assign reg_cell_debug_10 = reg_cell[10];
assign reg_cell_debug_11 = reg_cell[11];
assign reg_cell_debug_12 = reg_cell[12];
assign reg_cell_debug_13 = reg_cell[13];
assign reg_cell_debug_14 = reg_cell[14];
assign reg_cell_debug_15 = reg_cell[15];
assign reg_cell_debug_16 = reg_cell[16];
assign reg_cell_debug_17 = reg_cell[17];
assign reg_cell_debug_18 = reg_cell[18];
assign reg_cell_debug_19 = reg_cell[19];
assign reg_cell_debug_20 = reg_cell[20];
assign reg_cell_debug_21 = reg_cell[21];
assign reg_cell_debug_22 = reg_cell[22];
assign reg_cell_debug_23 = reg_cell[23];
assign reg_cell_debug_24 = reg_cell[24];
assign reg_cell_debug_25 = reg_cell[25];
assign reg_cell_debug_26 = reg_cell[26];
assign reg_cell_debug_27 = reg_cell[27];
assign reg_cell_debug_28 = reg_cell[28];
assign reg_cell_debug_29 = reg_cell[29];
assign reg_cell_debug_30 = reg_cell[30];
assign reg_cell_debug_31 = reg_cell[31];

/*genvar i;
generate
for (i = 0; i < 32; i++) begin : dump
    initial $dumpvars(0, reg_cell[i]);
end
endgenerate
*/
always @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i;
        for (i = 1; i < 32; i = i + 1) begin
            reg_cell[i] <= 0;
        end
    end else begin
        if (we && ws != 0) begin
            if (wb_ctrl == WB_IMM) begin
                reg_cell[ws][31:12] <= wd[31:12];
            end else begin    
                reg_cell[ws] <= wd;
            end
        end
    end
end

assign rd1 = (rs1 == 0) ? 32'b0 : reg_cell[rs1];
assign rd2 = (rs2 == 0) ? 32'b0 : reg_cell[rs2];
/* Output debug */
assign x7 = reg_cell[7];
assign x8 = reg_cell[8];
assign x9 = reg_cell[9];


endmodule
