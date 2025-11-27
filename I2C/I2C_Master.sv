module I2C_Master (
    input clk,
    input data_in,
    input rw,
    inout sda,
    output scl
);

localparam bit IDLE     = 3'b100;
localparam bit START    = 3'b000;
localparam bit ADDRESS  = 3'b001;
localparam bit RW       = 3'b010;
localparam bit STOP     = 3'b011;

logic [2:0] counter;

/* Detecção de mensagem */
always @(posedge scl) begin

end

always @(negedge scl) begin

end
/**************************/

always @(posedge clk) begin
    if (state != IDLE) begin
        counter <= counter + 1;
    end
    state <= next_state;
end

always @(posedge scl) begin

    if (state == ADDRESS) begin
        addrCount <= addrCount + 1;
    end
end

/* Máquina de estados inicial */
always_comb begin : send_block
    case (state)
        IDLE: begin
            scl = 1'b1;
            if (data_in) begin
                next_state = START;
            end
        end

        START: begin
            sda = 1'b0;
            scl = counter[2];
            next_state = ADDRESS;
        end

        ADDRESS: begin
            if (addrCount < 7) begin
                if (scl == 1'b0)
                    sda = addr[6 - addrCount];
            end else begin
                next_state = RW;
            end
        end

        RW: begin
            if (scl == 1'b0) begin
                sda = rw;
            end else begin
                next_state = ACK_RCV;
            end
        end

        STOP: begin
            if (scl == 1'b1) begin
                sda = 1'b1;
            end
        end

        default:
            next_state = state;
    endcase
end

always_comb begin : receive_block
    case (state)
        ACK_RCV: begin
            if (scl == 1'b1) begin
                ack_rcv = sda;
                next_state = (ack_rcv ? STOP : (rw ? DATA_RCV : DATA_SEND));
            end
        end

        DATA_RCV: begin
            if (scl == 1'b1) begin
                data_out
            end
        end

    default:
        next_state = state;
    endcase
end

endmodule

