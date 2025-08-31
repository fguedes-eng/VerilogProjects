`timescale 1ns/1ns

module UART_tb #(parameter WIDTH = 8) ();

//----------------------------------------------------------------
//Entradas do sistema:
//----------------------------------------------------------------

//-------------------------------------------
//Entradas:
//-------------------------------------------

    reg [WIDTH - 1:0] Data_In;
    reg clk;
    reg rst;
    reg In_rdy;
    reg [1:0] baud_select;
    reg parity_sel;
	reg Rx;

//-------------------------------------------
//Saídas:
//-------------------------------------------

    wire [WIDTH - 1:0] Data_Out;
    wire Overflow;
    wire Tx;
    wire Parity;
    wire ParityError;
    wire StopBitError;
    wire Out_rdy;


//----------------------------------------------------------------
//Parametros de clock:
//----------------------------------------------------------------

parameter BAUD_RATE_9600  = 2'b00;
parameter BAUD_RATE_19200 = 2'b01;
parameter BAUD_RATE_38400 = 2'b10;
parameter BAUD_RATE_57600 = 2'b11;

//Cats para tempos:
parameter BAUD_CYCLE = 104160;
parameter WAIT = 1041600;
parameter WAIT_TX = 350000;

//----------------------------------------------------------------
//Instância do top-level:
//----------------------------------------------------------------

UART dut(
//-------------------------------------------
//Entradas:
//-------------------------------------------

    .Data_In                (Data_In),
    .clk                    (clk),
    .rst                    (rst),
    .In_rdy                 (In_rdy),
    .baud_select            (baud_select),
    .parity_sel             (parity_sel),
	.Rx                     (Tx),

//-------------------------------------------
//Saídas:
//-------------------------------------------

    .Data_Out               (Data_Out),
    .Overflow               (Overflow),
    .Tx                     (Tx),
    .Parity                 (Parity),
    .ParityError            (ParityError),
    .StopBitError           (StopBitError),
    .Out_rdy                (Out_rdy)
);

//----------------------------------------------------------------
//Geração do clock global que alimenta o top:
//----------------------------------------------------------------

    initial begin
        clk = 0;
        forever #10 clk = ~clk; //50MHz
    end

    //Task de Reset
    task automatic reset;
    begin
    rst = 1; #5;
    end
    endtask

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
    reset();
    baud_select = BAUD_RATE_9600;
 //Limpeza de estados pré-sistemica
    /*$display
    (" Tempo | Data_In | clk | rst | In_rdy | baud_select | parity_sel | Tx | Data_Out | Overflow | Parity | ParityError | StopBitError | Out_rdy");
    $monitor
    ("%4dns  |   %08b  |  %b |  %b |   %b   |      %b     |      %b    | %b |    %b    |    %b    |    %b  |      %b     |      %b      |     %b   | ",

        //Sinais
        $time,                 
            //Entradas:
            Data_In,
            clk,
            rst,
            In_rdy,
            baud_select,
            parity_sel,
            Rx,

            //Saídas:
            Data_Out,
            Overflow,
            Tx,
            Parity,
            ParityError,
            StopBitError,
            Out_rdy
    ); */

    //1º Rotina de testes - Caso normal de transmisão 0x57:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b0;         
    Data_In = 8'h57;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT_TX;
    //2º - Casos de borda
    //1º Caso de borda - 0x00:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b1;         
    Data_In = 8'h00;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT_TX;
    //2º Caso de borda - 0x11:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b0;         
    Data_In = 8'h11;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT_TX;
    //3º Caso de borda - 0x22:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b1;         
    Data_In = 8'h22;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT_TX;
    //4º Caso de borda - 0x33:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b0;         
    Data_In = 8'h33;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT_TX;
    //5º Caso de borda - 0x44:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b1;         
    Data_In = 8'h44;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT_TX;
    //6º Caso de borda - 0x55:
    rst = 1'b0;             
    In_rdy = 0;    
    parity_sel = 1'b0;         
    Data_In = 8'h55;        #2;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;

    #WAIT;
    #WAIT;
    #WAIT;
    #WAIT;

    $finish;
end

endmodule
