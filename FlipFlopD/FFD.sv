module VrDff(
    input CLK, CLR, D,
    output reg Q
);

always @(posedge CLR) begin
    Q <= 0;
end

always @(posedge CLK) begin
    Q <= D;
end


endmodule