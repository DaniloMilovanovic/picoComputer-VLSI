module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] code
);
    reg[15:0] code_reg, code_next;
    reg [7:0] buffer, buffer_next;
    reg loading_state, loading_state_next;
    reg [3:0] loaded_bit_counter, loaded_bit_counter_next;
    reg parity_check, parity_check_next;
    reg parity_bit, parity_bit_next;

    assign out = code_reg;

    always @(negedge ps2_clk, negedge rst_n) begin
        if(!rst_n) begin
            loading_state <= 1'b0;
            loaded_bit_counter <= 4'h0;
            buffer <= 8'h00;
            parity_bit <= 1'b0;
            parity_check <= 1'b1;
            code_reg = 16'h0000;
        end
        else begin
            loading_state <= loading_state_next;
            loaded_bit_counter <= loaded_bit_counter_next;
            parity_bit <= parity_bit_next;
            parity_check <= parity_check_next;
            buffer <= buffer_next;
            code_reg <= code_next;
        end
    end

    always @(*) begin
        code_next = code_reg;
        loaded_bit_counter_next = 4'h0;
        parity_bit_next = parity_bit;
        parity_check_next = parity_check;
        loading_state_next = loading_state;
        buffer_next = buffer;

        //FSM with two states
        if(loading_state) begin
            if(loaded_bit_counter < 4'd8) begin //Load each bit into the buffer and calculate the parity bit

                buffer_next[loaded_bit_counter] = ps2_data;
                parity_check_next = parity_check ^ ps2_data;
                loaded_bit_counter_next = loaded_bit_counter + 1;

            end
            else if (loaded_bit_counter == 4'd8) begin

                parity_bit_next = ps2_data;
                loaded_bit_counter_next = loaded_bit_counter + 1;

            end
            else begin
                if(parity_bit == parity_check && ps2_data == 1'b1)
                    code_next = {code_reg[7:0], buffer};

                loading_state_next = 1'b0;

            end
        end
        else begin
            if(ps2_data == 0) begin
                loading_state_next = 1'b1;
                parity_bit_next = 1'b1; // Because PS2 uses odd parity (odd number of 1's is equal to 0)
            end
        end
    end
endmodule