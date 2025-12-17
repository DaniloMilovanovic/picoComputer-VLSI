module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] code
);

    reg state_reg, state_next;
    localparam idle = 1'b0, busy = 1'b1;
    
    reg [7:0] ps2_clk_debounce_buffer_reg;
    reg ps2_clk_debounce_reg;
    reg ps2_clk_debounce_prev;
    
    reg [3:0] remaining_bit_counter, remaining_bit_counter_next;
    reg [10:0] buffer, buffer_next; 
    reg parity;

    reg [15:0] code_reg, code_reg_next;

    assign code = code_reg;
    assign leds = {state_reg, ps2_clk_debounce_reg, ps2_data, code_reg[7:0]};

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            
            ps2_clk_debounce_buffer_reg <= 8'hff;
            ps2_clk_debounce_reg <= 1'b1;
            ps2_clk_debounce_prev <= 1'b1;
            state_reg <= idle;
            remaining_bit_counter <= 4'h0;
            buffer <= 11'h000;
            code_reg <= 16'h0000;
        end
        else begin

            ps2_clk_debounce_buffer_reg <= {ps2_clk_debounce_buffer_reg[6:0], ps2_clk};
            
            if (ps2_clk_debounce_buffer_reg == 8'hff)  // All bits are 1
                ps2_clk_debounce_reg <= 1'b1;
            else if (ps2_clk_debounce_buffer_reg == 8'h00)  // All bits are 0
                ps2_clk_debounce_reg <= 1'b0;
            
            ps2_clk_debounce_prev <= ps2_clk_debounce_reg;
            
            state_reg <= state_next;
            remaining_bit_counter <= remaining_bit_counter_next;
            buffer <= buffer_next;
            code_reg <= code_reg_next;
        end
    end

    wire ps2_clk_falling_edge = (ps2_clk_debounce_prev == 1'b1 && ps2_clk_debounce_reg == 1'b0);

    always @(*) begin
        state_next = state_reg;
        remaining_bit_counter_next = remaining_bit_counter;
        buffer_next = buffer;
        code_reg_next = code_reg;
        
        case (state_reg)
            idle: begin

                if (ps2_clk_falling_edge && ps2_data == 1'b0) begin

                    state_next = busy;
                    remaining_bit_counter_next = 4'd10;
                    buffer_next = 11'h000;
                end
            end
            
            busy: begin

                if (ps2_clk_falling_edge) begin

                    buffer_next = {ps2_data, buffer[10:1]};
                    remaining_bit_counter_next = remaining_bit_counter - 1;
                    
                    if (remaining_bit_counter == 4'd1) begin
                        state_next = idle;
                        
                        if (buffer[0] == 1'b0 && ps2_data == 1'b1)//Add a check for the parity bit
                            code_reg_next = {code_reg[7:0], buffer[9:2]};
                    end
                end
            end
            
            default: begin
                state_next = idle;
            end
        endcase
    end
endmodule
