module CPU #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input [DATA_WIDTH - 1:0] mem,
    input [DATA_WIDTH - 1:0] in,
    output we,
    output [ADDR_WIDTH - 1:0] addr,
    output [DATA_WIDTH - 1:0] data,
    output [DATA_WIDTH - 1:0] out,
    output [ADDR_WIDTH - 1:0] pc,
    output [ADDR_WIDTH - 1:0] sp
);

reg pc_cl, pc_ld, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il;
reg [5:0] pc_in;
wire [5:0] pc_out;
register #(.DATA_WIDTH(6)) PC(clk, rst_n, pc_cl, pc_ld, pc_in, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il, pc_out);

reg sp_cl, sp_ld, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il;
reg [5:0] sp_in;
wire [5:0] sp_out;
register #(.DATA_WIDTH(6)) SP(clk, rst_n, sp_cl, sp_ld, sp_in, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il, sp_out);

reg ir_cl, ir_ld, ir_inc, ir_dec, ir_sr, ir_ir, ir_sl, ir_il;
reg [31:0] ir_in;
wire [31:0] ir_out;
register #(.DATA_WIDTH(32)) IR(clk, rst_n, ir_cl, ir_ld, ir_in, ir_inc, ir_dec, ir_sr, ir_ir, ir_sl, ir_il, ir_out);

reg mar_cl, mar_ld, mar_inc, mar_dec, mar_sr, mar_ir, mar_sl, mar_il;
reg [5:0] mar_in;
wire [5:0] mar_out;
register #(.DATA_WIDTH(6)) MAR(clk, rst_n, mar_cl, mar_ld, mar_in, mar_inc, mar_dec, mar_sr, mar_ir, mar_sl, mar_il, mar_out);

reg mdr_cl, mdr_ld, mdr_inc, mdr_dec, mdr_sr, mdr_ir, mdr_sl, mdr_il;
reg [15:0] mdr_in;
wire [15:0] mdr_out;
register #(.DATA_WIDTH(16)) MDR(clk, rst_n, mdr_cl, mdr_ld, mdr_in, mdr_inc, mdr_dec, mdr_sr, mdr_ir, mdr_sl, mdr_il, mdr_out);

reg a_cl, a_ld, a_inc, a_dec, a_sr, a_ir, a_sl, a_il;
reg [5:0] a_in;
wire [5:0] a_out;
register #(.DATA_WIDTH(6)) A(clk, rst_n, a_cl, a_ld, a_in, a_inc, a_dec, a_sr, a_ir, a_sl, a_il, a_out);

reg [10:0] state_reg, state_next;

reg we_reg, we_next;
reg [ADDR_WIDTH - 1:0] addr_reg, addr_next;
reg [DATA_WIDTH - 1:0] data_reg, data_next;
reg [DATA_WIDTH - 1:0] out_reg, out_next;
reg [ADDR_WIDTH - 1:0] pc_reg, pc_next;
reg [ADDR_WIDTH - 1:0] sp_reg, sp_next;

assign we = we_reg;
assign addr = addr_reg;
assign data = data_reg;
assign out = out_reg;
assign pc = pc_reg;
assign sp = sp_reg;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_reg <= 1'b0;
        state_reg <= {10{1'b0}};
        we_reg <= 1'b0;
        addr_reg <= {ADDR_WIDTH - 1{1'b0}};
        data_reg <= {DATA_WIDTH - 1{1'b0}};
        out_reg <= {DATA_WIDTH - 1{1'b0}};
    end
end

endmodule