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
    
    // 800x600 @ 60Hz
    /*parameter H_DISPLAY = 800;
    parameter H_FP      = 40;
    parameter H_SYNC    = 128;
    parameter H_BP      = 88;
    parameter H_TOTAL   = 1056;
    
    parameter V_DISPLAY = 600;
    parameter V_FP      = 1;
    parameter V_SYNC    = 4;
    parameter V_BP      = 23;
    parameter V_TOTAL   = 628;

    parameter POLARITY = 1;*/
    // 800x600 @ 72Hz
    
    parameter H_DISPLAY = 800;
    parameter H_FP      = 56;
    parameter H_SYNC    = 120;
    parameter H_BP      = 64;
    parameter H_TOTAL   = 1040;
    
    parameter V_DISPLAY = 600;
    parameter V_FP      = 37;
    parameter V_SYNC    = 6;
    parameter V_BP      = 23;
    parameter V_TOTAL   = 666;

    parameter POLARITY = 1;

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
        hsync = ~POLARITY;
        vsync = ~POLARITY;
        h_pos_next = h_pos;
        v_pos_next = v_pos;
        
        //Counter
        if(h_pos == H_TOTAL - 1) begin
            if(v_pos == V_TOTAL - 1)
                v_pos_next = 0;
            else 
                v_pos_next = v_pos + 1;
            
            h_pos_next = 0;
        end
        else begin
            h_pos_next = h_pos + 1;
        end
        
        //Display left color on the left part of monitor, right color at the right part.
        if(h_pos < H_DISPLAY & v_pos < V_DISPLAY) begin
            if(h_pos < H_DISPLAY / 2)
                display_color = left_color;
            else 
                display_color = right_color;
        end
        else 
            display_color = 12'h000;
        
        //Horizontal and vertical sync
        if(h_pos > H_DISPLAY + H_FP - 1 && h_pos < H_DISPLAY + H_FP + H_SYNC)
            hsync = POLARITY;
        
        if(v_pos > V_DISPLAY + V_FP - 1 && v_pos < V_DISPLAY + V_FP + V_SYNC)
            vsync = POLARITY;
    end
endmodule