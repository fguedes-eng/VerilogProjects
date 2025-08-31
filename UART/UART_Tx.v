module UART_Tx #(parameter WIDTH = 8)
(
    input clk, //clock vindo do baud_rate
    input [WIDTH - 1:0] Data_In, //dado no barrament
    input rst,
    input Parity, //bit de paridade
    input Send_TX, //ativo manda a entrada para os registradores de buffer
    input FIFO_send,
    output reg Tx, //bit único sendo enviado Tx
    output reg Tx_Busy,
    output reg FIFO_full
);

/* Estados */
parameter  S0 = 3'b000;
parameter  S1 = 3'b001;
parameter  S2 = 3'b010;
parameter  S3 = 3'b011;
parameter  S4 = 3'b100;

reg [WIDTH - 1:0] FIFO [0:3];
reg [WIDTH - 1:0] nextFIFO [0:3];
reg [WIDTH - 1:0] nextTxBuffer;
reg [WIDTH - 1:0] TxBuffer;

reg [2:0] state; //estado atual
reg [2:0] nextState; //próximo estado
reg [3:0] counter; //contador
reg [3:0] nextCounter; //próximo contador
reg nextTx; //próximo bit de transmissão
reg nextFIFO_full;
reg nextTx_Busy;

reg [2:0] wr_ptr; 
reg [2:0] nextWr_ptr;
reg [2:0] rd_ptr;
reg [2:0] nextRd_ptr;

reg StopBit;
reg nextStopBit;


    /* Sequencial */
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Tx <= 1;
            wr_ptr <= 0;
            rd_ptr <= 0;
            FIFO[0] <= 0;
            FIFO[1] <= 0;
            FIFO[2] <= 0;
            FIFO[3] <= 0;
            TxBuffer <= 0;
            state <= S0;
            Tx_Busy <= 0;
            FIFO_full <= 0;
            StopBit <= 1;
        end else begin
            state <= nextState;
            counter <= nextCounter;
            Tx <= nextTx;
            FIFO[0] <= nextFIFO[0];
            FIFO[1] <= nextFIFO[1];
            FIFO[2] <= nextFIFO[2];
            FIFO[3] <= nextFIFO[3];
            TxBuffer <= nextTxBuffer;
            wr_ptr <= nextWr_ptr;
            rd_ptr <= nextRd_ptr;
            FIFO_full <= nextFIFO_full;
            Tx_Busy <= nextTx_Busy;
            StopBit <= nextStopBit;
        end
    end

    /* FIFO */
    always @(*) begin
        // Mantém os valores atuais por default
        nextFIFO[0] = FIFO[0];
        nextFIFO[1] = FIFO[1];
        nextFIFO[2] = FIFO[2];
        nextFIFO[3] = FIFO[3];
        nextWr_ptr = wr_ptr;
        nextFIFO_full = FIFO_full;

        if (FIFO_send) begin
            // Escreve o dado na posição atual
            nextFIFO[wr_ptr[1:0]] = Data_In;
            // Incrementa ponteiro circularmente
            //nextWr_ptr = (wr_ptr + 1) & 3;
            // Atualiza flag full
            if (((nextWr_ptr + 1) & 3) == rd_ptr) begin
                nextWr_ptr = wr_ptr;
                nextFIFO_full = 1;
            end
            else begin
                nextWr_ptr = (wr_ptr + 1) & 3;
                nextFIFO_full = 0;
            end
        end
    end

    /* Máquina de Estados */
    always @(*) begin
        case (state)
            /* Estado inicial, aguarda dados */
            S0: begin
                nextTx_Busy = 0;
                nextTx = 1;
                nextStopBit = 1;
                nextCounter = 4'b0000;
                nextRd_ptr = rd_ptr;
                if (Send_TX == 1 && rd_ptr != wr_ptr) begin
                    nextTxBuffer = FIFO[rd_ptr[1:0]]; // lê o dado do FIFO
                    nextRd_ptr = (rd_ptr + 1) & 3;    // incrementa circularmente
                    nextState = S1;                   // inicia transmissão
                end
                else begin
                    nextState = state;
                    nextTxBuffer = TxBuffer;
                end
            end
            /* Envia start bit */
            S1: begin
                nextTx_Busy = 1;
                nextTx = 0;
                nextCounter = 4'b0000;
                nextState = S2;
            end
            /* Envia todos os bits do barramento em sequência */
            S2: begin
                nextCounter = counter + 4'b0001;
                nextTx = TxBuffer[counter];
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
            end
        endcase
    end
endmodule
