module vga (
    input clk,
    input rst_n,
    input [23:0] code,
    output reg hsync,
    output reg vsync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
);
    wire [11:0] left_color, right_color;
    reg [11:0] display_color;

    reg [10:0] h_pos, h_pos_next;
    reg [10:0] v_pos, v_pos_next;

    assign right_color = code[11:0];
    assign left_color = code[23:12];

    assign {red, green, blue} = display_color;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            h_pos <= 11'd0;
            v_pos <= 11'd0;
        end
        else begin
            h_pos <= h_pos_next;
            v_pos <= v_pos_next;
        end
    end

    always @(*) begin
        hsync = 1'b0;
        vsync = 1'b0;
        h_pos_next = h_pos;
        v_pos_next = v_pos;

        //Counter
        if(h_pos == 1039) begin
            if(v_pos == 665)
                v_pos_next = 0;
            else 
                v_pos_next = v_pos + 1;
            
            h_pos_next = 0;
        end
        else begin
            h_pos_next = h_pos + 1;
        end
        
        //Display left color on the left part of monitor, right color at the right part.
        if(h_pos < 400 && v_pos < 600) 
            display_color = left_color;
        else if(h_pos > 399 && h_pos < 800 && v_pos < 600)
            display_color = right_color;
        else
            display_color = 12'h000;
        
        //Horizontal and vertical sync
        if(h_pos > 855 && h_pos < 976)
            hsync = 1;
        
        if(v_pos > 636 && v_pos < 643)
            vsync = 1;

    end
endmodule