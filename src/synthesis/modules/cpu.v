module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
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
assign pc = pc_out;
assign sp = sp_out;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_reg <= 1'b0;
        state_reg <= {10{1'b0}};
        we_reg <= 1'b0;
        addr_reg <= {ADDR_WIDTH - 1{1'b0}};
        data_reg <= {DATA_WIDTH - 1{1'b0}};
        out_reg <= {DATA_WIDTH - 1{1'b0}};
        pc_reg <= {ADDR_WIDTH - 1{1'b0}};
        sp_reg <= {ADDR_WIDTH - 1{1'b0}};
    end
    else begin
        out_reg <= out_next;
        state_reg <= state_next;
        we_reg <= we_next;
        addr_reg <= addr_next;
        data_reg <= data_next;
        out_reg <= out_next;
        pc_reg <= pc_next;
        sp_reg <= sp_next;
    end
end

always @(*) begin
    state_next = state_reg;
    we_next = we_reg;
    addr_next = addr_reg;
    data_next = data_reg;
    out_next = out_reg;
    pc_next = pc_reg;
    sp_next = sp_reg;

    pc_cl = 1'b0;
    pc_ld = 1'b0;
    pc_inc = 1'b0;
    pc_dec = 1'b0;
    pc_sr = 1'b0;
    pc_ir = 1'b0;
    pc_sl = 1'b0;
    pc_il = 1'b0;
    pc_in = 6'b0;

    sp_cl = 1'b0;
    sp_ld = 1'b0;
    sp_inc = 1'b0;
    sp_dec = 1'b0;
    sp_sr = 1'b0;
    sp_ir = 1'b0;
    sp_sl = 1'b0;
    sp_il = 1'b0;
    sp_in = 6'b0;

    ir_cl = 1'b0;
    ir_ld = 1'b0;
    ir_inc = 1'b0;
    ir_dec = 1'b0;
    ir_sr = 1'b0;
    ir_ir = 1'b0;
    ir_sl = 1'b0;
    ir_il = 1'b0;
    ir_in = 32'b0;

    mar_cl = 1'b0;
    mar_ld = 1'b0;
    mar_inc = 1'b0;
    mar_dec = 1'b0;
    mar_sr = 1'b0;
    mar_ir = 1'b0;
    mar_sl = 1'b0;
    mar_il = 1'b0;
    mar_in = 6'b0;

    mdr_cl = 1'b0;
    mdr_ld = 1'b0;
    mdr_inc = 1'b0;
    mdr_dec = 1'b0;
    mdr_sr = 1'b0;
    mdr_ir = 1'b0;
    mdr_sl = 1'b0;
    mdr_il = 1'b0;
    mdr_in = 16'b0;

    a_cl = 1'b0;
    a_ld = 1'b0;
    a_inc = 1'b0;
    a_dec = 1'b0;
    a_sr = 1'b0;
    a_ir = 1'b0;
    a_sl = 1'b0;
    a_il = 1'b0;
    a_in = 6'b0;

    case (state_reg)
        10'd0: begin //initialize registers
            we_next = 1'b0;
            addr_next = {ADDR_WIDTH - 1{1'b0}};
            data_next = {DATA_WIDTH - 1{1'b0}};
            out_next = {DATA_WIDTH - 1{1'b0}};
            pc_next = {ADDR_WIDTH - 1{1'b0}};
            sp_next = {ADDR_WIDTH - 1{1'b0}};
            
            pc_in = 6'd8;
            pc_ld = 1'b1;

            sp_in = ADDR_WIDTH - 1;
            sp_ld = 1'b1;


        end
        10'd1: begin

        end

    endcase
end
endmodule