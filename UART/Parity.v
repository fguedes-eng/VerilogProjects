module Parity(
    input parity_sel,
    input [8 - 1:0] dataIn,
    output parity,
    output selected_parity
);

parameter PAR = 0;
parameter IMPAR = 1;

assign parity = (parity_sel == PAR ? ^(dataIn) : ~(^(dataIn)));
assign selected_parity = parity_sel;

endmodule