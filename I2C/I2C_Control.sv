module I2C_Control (

);

always_comb begin
    case (state)
        IDLE: begin
            if (data_in) begin
                next_state = START;
            end
        end

        START: begin
            if (scl == 1'b1) begin
                //sda_start = 1'b1;
                next_state = ADDRESS;
            end
        end

        ADDRESS: begin
            if (scl == 1'b0) begin
                //sda_address = 1'b1;
                next_addrCount = addrCount + 1;
            end
        end

        DATA: begin
            if (data_in) begin
                if (scl == 1'b0) begin
                    
                end
            end
        end

        STOP: begin

        end

        default:
    endcase
end

endmodule