module VrDlatchCE(
    input D, G, GE, CLR;
    output reg Q;
)

always @(CLR) begin
    Q <= 0;
end

always @(D or G or GE or CLR) begin
    if (CLR == 1) Q <= 0;
    else if (G == 1 && GE == 1) begin
        Q <= D;
    end
end

endmodule