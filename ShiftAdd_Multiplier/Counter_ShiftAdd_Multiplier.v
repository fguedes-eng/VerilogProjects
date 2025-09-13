module Counter_ShiftAdd_Multiplier (
    input clk,
    input rst,
    input ld_count,
    output reg [2:0] count
);
    wire [2:0] nextCount;

    always @(posedge clk) begin
        count <= nextCount;
    end

    assign nextCount = (ld_count == 1) ? (count + 1) : count;


endmodule