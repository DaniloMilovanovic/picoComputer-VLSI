module register (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [3:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [3:0] out
);
    
    reg [3:0] out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        
        if(!rst_n) begin 
            out_reg <= 4'h0;
        end
        else begin 
            out_reg <= out_next;
        end

    end

    always @(*) begin
        out_next = out_reg;
        
        casex ({cl, ld, inc, dec, sr, sl})
            6'b1xxxxx: out_next = 4'h0;//clear
            6'b01xxxx: out_next = in;//load
            6'b001xxx: out_next = out_reg + 1;//inc
            6'b0001xx: out_next = out_reg - 1;//dec
            6'b00001x: out_next = {ir , out_reg[3:1]};//shift right
            6'b000001: out_next = {out_reg[2:0], il};//shift left
            default: out_next = out_reg;
        endcase
        
    end

endmodule