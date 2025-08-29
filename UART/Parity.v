module Parity(
    input parity_sel,
    input [8 - 1:0] dataIn,
    output parity
);

parameter PAR = 0;
parameter IMPAR = 1;

assign parity = (parity_sel == PAR ? ^(dataIn) : ~(^(dataIn)));

endmodule