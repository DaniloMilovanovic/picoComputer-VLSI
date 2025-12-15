module scan_codes (
    input clk,
    input rst_n,
    input [15:0] code,
    input status,
    output control,
    output [3:0] num
);
    localparam 
        key_0 = 16'hF045,
        key_1 = 16'hF016,
        key_2 = 16'hF01E,
        key_3 = 16'hF026,
        key_4 = 16'hF025,
        key_5 = 16'hF02E,
        key_6 = 16'hF036,
        key_7 = 16'hF03D,
        key_8 = 16'hF03E,
        key_9 = 16'hF046,
        num_0 = 16'hF070, 
        num_1 = 16'hF069,
        num_2 = 16'hF072,
        num_3 = 16'hF07A,
        num_4 = 16'hF06B,
        num_5 = 16'hF073,
        num_6 = 16'hF074,
        num_7 = 16'hF06C,
        num_8 = 16'hF075,
        num_9 = 16'hF07D;

    reg [3:0] num_reg, num_next;
    reg control_reg, control_next;
    
    assign num = num_reg;
    assign control = control_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            num_reg <= 4'h0;
            control_reg <= 1'b0;
        end
        else begin
            num_reg <= num_next;
            control_reg <= control_next;
        end
    end

    always @(*) begin
        num_next = num_reg;
        control_next = control_reg;

        if(status) begin
            if(!control_reg) begin
                
                control_next = 1'b1;

                case (code)
                    key_0: num_next = 4'd0; 
                    key_1: num_next = 4'd1;
                    key_2: num_next = 4'd2;
                    key_3: num_next = 4'd3;
                    key_4: num_next = 4'd4;
                    key_5: num_next = 4'd5;
                    key_6: num_next = 4'd6;
                    key_7: num_next = 4'd7;
                    key_8: num_next = 4'd8;
                    key_9: num_next = 4'd9;
                    num_0: num_next = 4'd0;
                    num_1: num_next = 4'd1;
                    num_2: num_next = 4'd2;
                    num_3: num_next = 4'd3;
                    num_4: num_next = 4'd4;
                    num_5: num_next = 4'd5;
                    num_6: num_next = 4'd6;
                    num_7: num_next = 4'd7;
                    num_8: num_next = 4'd8;
                    num_9: num_next = 4'd9;
                    default: begin
                        control_next = 1'b0;
                    end
                endcase
            end
        end
        else begin
            control_next = 1'b0;
            num_next = 4'h0;
        end
    end

endmodule