module debouncer (
    input clk,
    input rst_n,
    input in,
    output out
);
    
    localparam on_cnt = 2**8;

    reg [32:0] cnt_reg, cnt_next;
    reg ff1_reg, ff1_next;
    reg ff2_reg, ff2_next;
    reg out_reg, out_next;

    assign out = out_reg;


    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 1'b0;
            cnt_reg <= 1'b0;
            ff1_reg <= 1'b0;
            ff2_reg <= 1'b0;
        end
        else begin
            out_reg <= out_next;
            cnt_reg <= cnt_next;
            ff1_reg <= ff1_next;
            ff2_reg <= ff2_next;
        end
    end
    
    always @(*) begin

        ff1_next = in;
        ff2_next = ff1_reg;

        if(ff1_reg ^ ff2_reg) //detect state change
            cnt_next = 1'b0;
        else
            cnt_next = cnt_reg + 1'b1;
        
        if(cnt_reg == 50_000) //if it overflows, it will just give the same number again
            out_next = ff1_reg;
        else
            out_next = out_reg;

    end
    
endmodule