module Instruction_memory (
    input [9:0] addr,
    input [31:0] mem_input [0:255],
    output [31:0] rd
);

logic [31:0] mem [0:255];

assign mem = mem_input;
assign rd = mem[addr >> 2];

endmodule
