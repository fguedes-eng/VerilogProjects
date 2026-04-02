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
      	default:
            rd_data = 32'd0;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i;
      for (i = 0; i <= 1023; i = i + 1) begin
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
          	default: begin
            end
        endcase
    end
end

endmodule
