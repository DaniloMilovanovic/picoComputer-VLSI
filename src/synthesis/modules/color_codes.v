module color_codes (
    input [5:0] num,
    output reg [23:0] code
);
    wire [3:0] ones, tens;
    
    assign ones = num % 10;
    assign tens = (num / 10) % 10;


    localparam 
        black = 12'h000,
        red = 12'hF00,
        orange = 12'hF80,
        yellow = 12'hFF0,
        green = 12'h0F0,
        cyan = 12'h0FF,
        light_blue = 12'h08F,
        blue = 12'h00F,
        magenta = 12'hF0F,
        white = 12'hFFF;

    always @(*) begin
        case (ones)
            4'h0: code[11:0] = black;
            4'h1: code[11:0] = red;
            4'h2: code[11:0] = orange;
            4'h3: code[11:0] = yellow;
            4'h4: code[11:0] = green;
            4'h5: code[11:0] = cyan;
            4'h6: code[11:0] = light_blue;
            4'h7: code[11:0] = blue;
            4'h8: code[11:0] = magenta;
            4'h9: code[11:0] = white;
            default: code[11:0] = black;
        endcase
        case (tens)
            4'h0: code[23:12] = black;
            4'h1: code[23:12] = red;
            4'h2: code[23:12] = orange;
            4'h3: code[23:12] = yellow;
            4'h4: code[23:12] = green;
            4'h5: code[23:12] = cyan;
            4'h6: code[23:12] = light_blue;
            4'h7: code[23:12] = blue;
            4'h8: code[23:12] = magenta;
            4'h9: code[23:12] = white;
            default: code[23:12] = black;
        endcase
    end

endmodule