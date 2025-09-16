`include "log2_func.vh"

module Counter_ShiftAdd_Multiplier #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input ld_count,
    output reg [COUNT_DEPTH:0] count
);

    localparam COUNT_DEPTH = log2(WIDTH);

    wire [COUNT_DEPTH:0] nextCount;

    always @(posedge clk or posedge rst) begin
        if (rst) count <= 0;
        else count <= nextCount;
    end

    assign nextCount = (ld_count == 1) ? (count + 1) : count;


endmodule