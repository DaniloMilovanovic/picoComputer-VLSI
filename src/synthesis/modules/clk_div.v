module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output out
);
    reg [32:0] clk_num_reg, clk_num_next;
    reg out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 1'b0;
            clk_num_reg <= 1'b0;
        end
        else begin
            out_reg <= out_next;
            clk_num_reg <= clk_num_next;
        end
    end

    always @(*) begin
        if(clk_num_reg == DIVISOR) begin
            out_next = 1'b1;
            clk_num_next = 1'b0;
        end
        else begin
            out_next = 1'b0;
            clk_num_next = clk_num_reg + 1'b1;
        end
    end
endmodule