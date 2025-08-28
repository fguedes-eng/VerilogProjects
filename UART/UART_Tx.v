module moduleName (
    input [8 - 1:0] A;
    output reg Tx;
);


    always @(posedge clk) begin
        state <= nextState;
        counter <= nextCounter;
    end

    always @(*) begin
        case (state)
            S0:
                Tx = 1;
                nextCounter = 0;
            S1:
                Tx = 0;
                nextCounter = 0;
                nextState = S2;
            S2:
                nextCounter = counter + 1;
                Tx = A[counter];
                if (counter == 7) begin
                    nextState = S3;
                end
            S3:
                Tx = Parity;
                nextState = S4;

            S4:
                Tx = StopBit;
                nextState = S0;

            default:
                nextState = S0;
        endcase
    end
endmodule