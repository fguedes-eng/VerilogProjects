module Tx (
    input [8 - 1:0] DataIn, //dado no barramento
    input clk, //clock
    input rst,
    input Parity, //bit de paridade
    input StopBit, //bit de Stop
    input bit_send, //ativo manda a entrada para os registradores de buffer
    input RW, //TODO: Indica se está lendo ou escrevendo (integrar Tx com Rx para comunicação full duplex)
    output reg Tx //bit único sendo enviado Tx
);

/* Estados */
parameter  S0 = 3'b000;
parameter  S1 = 3'b001;
parameter  S2 = 3'b010;
parameter  S3 = 3'b011;
parameter  S4 = 3'b100;

reg [3:0] state; //estado atual
reg [3:0] nextState; //próximo estado
reg [3:0] counter; //contador
reg [3:0] nextCounter; //próximo contador
reg nextTx; //próximo bit de transmissão
reg [8 - 1:0] BufferIn; //buffer que pode receber a entrada diretamente ou do buffer reserva, e envia a Tx
reg [8 - 1:0] WaitBufferIn; //buffer que recebe a entrada caso esteja ocorrendo um envio
reg [8 - 1:0] nextBufferIn; //próximo dado do buffer de envio
reg [8 - 1:0] nextWaitBufferIn; //próximo dado do buffer de espera
reg WaitBufferInActive; //flag que indica se existe pendência no buffer de espera para ter os dados capturados
reg nextWaitBufferInActive; //próximo estado da flag anterior
reg bit_send_prev;
wire bit_send_edge;
reg bit_send_sync1;
reg bit_send_sync2;

    /* Sequencial */
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Tx <= 1;
            bit_send_sync1 <= 0;
            bit_send_sync2 <= 0;
            bit_send_prev <= 0;
        end else begin
            state <= nextState;
            counter <= nextCounter;
            Tx <= nextTx;
            BufferIn <= nextBufferIn;
            WaitBufferIn <= nextWaitBufferIn;
            WaitBufferInActive <= nextWaitBufferInActive;

            bit_send_sync1 <= bit_send;
            bit_send_sync2 <= bit_send_sync1;
            bit_send_prev <= bit_send_sync2;
        end
    end

    /* Ativa buffer reserva para não perder envio de dados */
    always @(*) begin
        /* Descarta quaisquer bits se o buffer de espera estiver cheio */
        if (WaitBufferInActive) begin
            nextBufferIn = BufferIn;
            nextWaitBufferInActive = WaitBufferInActive;
        end
        /* Recebe dados no buffer de espera se estiver no meio de uma transmissão */ 
        else if (bit_send_edge == 1 && state != S0) begin
            nextWaitBufferIn = DataIn;
            nextWaitBufferInActive = 1;
        end else begin
            nextWaitBufferIn = WaitBufferIn;
            nextWaitBufferInActive = WaitBufferInActive;
        end
    end

    /* Máquina de Estados */
    always @(*) begin
        case (state)
            /* Estado inicial, aguarda dados */
            S0: begin
                nextTx = 1;
                nextCounter = 4'b0000;
                if (WaitBufferInActive) begin
                    nextState = S1;
                    nextBufferIn = WaitBufferIn;
                    nextWaitBufferInActive = 0;
                end
                else if (bit_send_edge == 1) begin
                    nextState = S1;
                    nextBufferIn = DataIn;
                end else begin
                    nextState = state;
                end
            end
            /* Envia start bit */
            S1: begin
                nextTx = 0;
                nextCounter = 4'b0000;
                nextState = S2;
            end
            /* Envia todos os bits do barramento em sequência */
            S2: begin
                nextCounter = counter + 4'b0001;
                nextTx = BufferIn[counter];
                if (counter == 7) begin
                    nextState = S3;
                end else begin
                    nextState = S2;
                end
            end
            /* Envia o bit de paridade */
            S3: begin
                nextTx = Parity;
                nextState = S4;
            end
            /* Envia o stop bit */
            S4: begin
                nextTx = StopBit;
                nextState = S0;
            end

            default: begin
                nextState = S0;
                WaitBufferInActive = 0;
            end
        endcase
    end

    assign bit_send_edge = bit_send_sync2 & ~bit_send_prev;
endmodule