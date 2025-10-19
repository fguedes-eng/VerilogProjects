import Instructions::*;

module Data_memory(
    input clk,
    input rst,
    input [11:0] mem_addr,
    input [31:0] wr_data,
    input we,
    input [2:0] read_size,
    output logic [31:0] rd_data
);

logic [7:0] mem_cell [0:1023];

logic [7:0] mem_cell_debug_0;
logic [7:0] mem_cell_debug_1;
logic [7:0] mem_cell_debug_2;
logic [7:0] mem_cell_debug_3;
logic [7:0] mem_cell_debug_4;
logic [7:0] mem_cell_debug_5;
logic [7:0] mem_cell_debug_6;
logic [7:0] mem_cell_debug_7;
logic [7:0] mem_cell_debug_8;
logic [7:0] mem_cell_debug_9;
logic [7:0] mem_cell_debug_10;
logic [7:0] mem_cell_debug_11;
logic [7:0] mem_cell_debug_12;
logic [7:0] mem_cell_debug_13;
logic [7:0] mem_cell_debug_14;
logic [7:0] mem_cell_debug_15;
logic [7:0] mem_cell_debug_16;
logic [7:0] mem_cell_debug_17;
logic [7:0] mem_cell_debug_18;
logic [7:0] mem_cell_debug_19;
logic [7:0] mem_cell_debug_20;
logic [7:0] mem_cell_debug_21;
logic [7:0] mem_cell_debug_22;
logic [7:0] mem_cell_debug_23;
logic [7:0] mem_cell_debug_24;
logic [7:0] mem_cell_debug_25;
logic [7:0] mem_cell_debug_26;
logic [7:0] mem_cell_debug_27;
logic [7:0] mem_cell_debug_28;
logic [7:0] mem_cell_debug_29;
logic [7:0] mem_cell_debug_30;
logic [7:0] mem_cell_debug_31;

assign mem_cell_debug_0 = mem_cell[0];
assign mem_cell_debug_1 = mem_cell[1];
assign mem_cell_debug_2 = mem_cell[2];
assign mem_cell_debug_3 = mem_cell[3];
assign mem_cell_debug_4 = mem_cell[4];
assign mem_cell_debug_5 = mem_cell[5];
assign mem_cell_debug_6 = mem_cell[6];
assign mem_cell_debug_7 = mem_cell[7];
assign mem_cell_debug_8 = mem_cell[8];
assign mem_cell_debug_9 = mem_cell[9];
assign mem_cell_debug_10 = mem_cell[10];
assign mem_cell_debug_11 = mem_cell[11];
assign mem_cell_debug_12 = mem_cell[12];
assign mem_cell_debug_13 = mem_cell[13];
assign mem_cell_debug_14 = mem_cell[14];
assign mem_cell_debug_15 = mem_cell[15];
assign mem_cell_debug_16 = mem_cell[16];
assign mem_cell_debug_17 = mem_cell[17];
assign mem_cell_debug_18 = mem_cell[18];
assign mem_cell_debug_19 = mem_cell[19];
assign mem_cell_debug_20 = mem_cell[20];
assign mem_cell_debug_21 = mem_cell[21];
assign mem_cell_debug_22 = mem_cell[22];
assign mem_cell_debug_23 = mem_cell[23];
assign mem_cell_debug_24 = mem_cell[24];
assign mem_cell_debug_25 = mem_cell[25];
assign mem_cell_debug_26 = mem_cell[26];
assign mem_cell_debug_27 = mem_cell[27];
assign mem_cell_debug_28 = mem_cell[28];
assign mem_cell_debug_29 = mem_cell[29];
assign mem_cell_debug_30 = mem_cell[30];
assign mem_cell_debug_31 = mem_cell[31];

always @(*) begin
    case (read_size)
        MEM_BYTE_SIGNED:
            rd_data = {{24{mem_cell[mem_addr][7]}}, mem_cell[mem_addr]};
        MEM_HALFWORD_SIGNED:
            rd_data = {{16{mem_cell[mem_addr][7]}}, mem_cell[mem_addr], mem_cell[mem_addr + 1]};
        MEM_WORD_SIGNED:
            rd_data = {mem_cell[mem_addr], mem_cell[mem_addr + 1], mem_cell[mem_addr + 2], mem_cell[mem_addr + 3]};
        MEM_BYTE_UNSIGNED:
            rd_data = {24'd0, mem_cell[mem_addr]};
        MEM_HALFWORD_UNSIGNED:
            rd_data = {16'd0, mem_cell[mem_addr], mem_cell[mem_addr + 1]};
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i;
        for (i = 0; i < 1023; i = i + 1) begin
            mem_cell[i] <= 8'd0;
        end
    end 
    else if (we) begin
        case (read_size)
            MEM_BYTE_SIGNED, MEM_BYTE_UNSIGNED:
                mem_cell[mem_addr] <= wr_data[7:0];
            MEM_HALFWORD_SIGNED, MEM_HALFWORD_UNSIGNED:
                {mem_cell[mem_addr], mem_cell[mem_addr + 1]} <= wr_data[15:0];
            MEM_WORD_SIGNED:
                {mem_cell[mem_addr], mem_cell[mem_addr + 1], mem_cell[mem_addr + 2], mem_cell[mem_addr + 3]} <= wr_data;
        endcase
    end
end

endmodule