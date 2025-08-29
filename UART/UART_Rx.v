module Rx (
    input Rx, //entrada Rx de um bit serial
    input clk, //clk
    output reg [8 - 1:0] DataOut //saída no barramento
);

/* Estados */
parameter  S0 = 3'b000;
parameter  S1 = 3'b001;
parameter  S2 = 3'b010;
parameter  S3 = 3'b011;
parameter  S4 = 3'b100;

reg [3:0] state; //estado atual
reg [3:0] nextState; //próximo estado;
reg [3:0] counter; //contador
reg [3:0] nextCounter; //próximo contador
reg [8 - 1:0] RxBuffer; //buffer que segura os dados sendo enviados em série, pra jogar paralelo na saída
reg [8 - 1:0] nextRxBuffer; //próximo dado do buffer anterior
reg read_end; //indica fim da leitura


    /* Sequencial */
    always @(posedge clk) begin
        state <= nextState;
        counter <= nextCounter;
        RxBuffer <= nextRxBuffer;
    end

    /* Máquina de estados */
    always @(*) begin
        case (state)
            /* Aguarda start bit */
            S0: begin
                nextCounter = 4'b0000;
                if (Rx == 0) begin
                    nextState = S1;
                end else begin
                    nextState = state;
                end
            end
            /* Coloca todos os bits da mensagem no buffer */
            S1: begin
                nextCounter = counter + 4'b0001;
                nextRxBuffer[counter] = Rx;
                if (counter == 7) begin
                    nextState = S2;
                end else begin
                    nextState = S1;
                end
            end
            /* TODO: checa paridade */
            S2: begin
                //parity check
                nextState = S3;
            end
            /* TODO: Tratar check do stop bit */
            S3: begin
                if (Rx == 1) begin
                    nextState = S4;
                end else begin
                    //tratamento de erro - stop bit != 1 
                    nextState = S4;
                end
            end
            /* Joga o conteúdo do buffer na saída em paralelo, e indica o fim da leitura */
            S4: begin
                DataOut = RxBuffer;
                read_end = 1;
                nextState = S0;
            end

            default: begin
                nextState = S0;
                read_end = 0;
            end

        endcase
    end

endmodule