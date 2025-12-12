module red (
    input clk,
    input rst_n,
    input in,
    output out
);

reg prev_state1_reg, prev_state1_staged;
reg prev_state2_reg, prev_state2_staged;

assign out = !prev_state2_reg & prev_state1_reg;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        prev_state1_reg <= 1'b0;
        prev_state2_reg <= 1'b0;
    end
    else begin
        prev_state1_reg <= prev_state1_staged;
        prev_state2_reg <= prev_state2_staged;
    end
end

always @(*) begin
    prev_state1_staged = in;
    prev_state2_staged = prev_state1_reg;
end
endmodule