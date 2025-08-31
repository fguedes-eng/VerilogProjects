module UART_Rx #(parameter WIDTH = 8)
(
    input Rx,                  // entrada Rx de um bit serial
    input clk,                 // clk
    input rst,                 // reset assíncrono
    input selected_parity,
    output reg [WIDTH - 1:0] Data_Out,  // saída no barramento
    output reg ParityError,
    output reg StopBitError,
    output reg Out_rdy          // indica que Data_Out está válido
);

/* Estados */
parameter  S0 = 3'b000;
parameter  S1 = 3'b001;
parameter  S2 = 3'b010;
parameter  S3 = 3'b011;
parameter  S4 = 3'b100;

parameter PAR   = 0;
parameter IMPAR = 1;

reg [2:0] state;       // estado atual
reg [2:0] nextState;   // próximo estado
reg [3:0] counter;     // contador
reg [3:0] nextCounter; // próximo contador
reg [7:0] nextDataOut; // próximo dado do buffer anterior
reg incomingParity;
reg nextOut_rdy;
reg nextParityError;
reg nextStopBitError;

/* Sequencial */
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state     <= S0;
        counter   <= 4'b0;
        Data_Out   <= 8'b0;
        ParityError  <= 0;
        StopBitError <= 0;
        Out_rdy      <= 0;
    end else begin
        state     <= nextState;
        counter   <= nextCounter;
        Data_Out   <= nextDataOut;
        Out_rdy <= nextOut_rdy;
        ParityError <= nextParityError;
        StopBitError <= nextStopBitError;
        // Flags são atualizadas combinacionalmente em always @(*)
    end
end

/* Máquina de estados */
always @(*) begin
    // defaults
    nextState           = state;
    nextCounter         = counter;
    nextDataOut         = Data_Out;
    nextParityError     = 0;
    nextStopBitError    = 0;
    nextOut_rdy         = 0;

    case (state)
        /* Aguarda start bit */
        S0: begin
            nextCounter = 4'b0000;
            if (Rx == 0)
                nextState = S1;
        end

        /* Coleta todos os bits da mensagem */
        S1: begin
            nextCounter       = counter + 4'b0001;
            nextDataOut[counter] = Rx;
            if (counter == 7)
                nextState = S2;
        end

        /* Checa paridade */
        S2: begin
            incomingParity = Rx;
            if (selected_parity == PAR)
                nextParityError = ( (^Data_Out) != incomingParity );
            else
                nextParityError = ( (~^Data_Out) != incomingParity );
            nextState = S3;
        end

        /* Check do stop bit */
        S3: begin
            if (Rx == 1)
                nextState = S4;
            else begin
                nextStopBitError = 1;
                nextState = S4;
            end
        end

        /* Indica fim da leitura */
        S4: begin
            nextOut_rdy = 1;   // Data_Out válido
            nextState   = S0;
        end

        default: begin
            nextState = S0;
        end
    endcase
end

endmodule
