module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [1:0] kbd,
    input [2:0] btn,
    input [8:0] sw,
    output [13:0] mnt,
    output [9:0] led,
    output [27:0] hex
);

wire clk_slow;

wire [DATA_WIDTH - 1:0] mem_data_output;
wire [DATA_WIDTH - 1:0] mem_data_input;
wire [ADDR_WIDTH - 1:0] mem_addr;
wire mem_we;
wire [ADDR_WIDTH - 1:0] pc_out, sp_out;
wire control, status;
wire [DATA_WIDTH - 1:0] cpu_out;
wire [3:0] ones_pc, tens_pc, ones_sp, tens_sp;

wire [3:0] ps2_num;

wire kbd_clk, kbd_data;

wire [15:0] ps2_code;
wire [23:0] vga_code;

assign kbd_clk = kbd[0];
assign kbd_data = kbd[1];


clk_div #(.DIVISOR(DIVISOR)) 
clk_div_inst(
    .clk(clk), 
    .rst_n(rst_n), 
    .out(clk_slow)
);


cpu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) 
cpu_inst(
    .clk(clk_slow), 
    .rst_n(rst_n),
    .mem(mem_data_output),
    .in({{DATA_WIDTH - 4{1'b0}}, ps2_num}),
    .control(control),
    .status(status),
    .we(mem_we),
    .addr(mem_addr),
    .data(mem_data_input),
    .pc(pc_out),
    .sp(sp_out),
    .out(cpu_out)
);

assign led[4:0] = cpu_out[4:0];

assign led[5] = status;

memory #(.FILE_NAME(FILE_NAME), .DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))
memory_inst(
    .clk(clk_slow),
    .we(mem_we),
    .addr(mem_addr),
    .data(mem_data_input),
    .out(mem_data_output)
);


ps2 ps2_inst(
    .clk(clk), 
    .clk_slow(clk_slow),
    .rst_n(rst_n), 
    .ps2_clk(kbd_clk), 
    .ps2_data(kbd_data), 
    .code(ps2_code)
);

scan_codes scan_codes_inst(
    .clk(clk_slow), 
    .rst_n(rst_n), 
    .code(ps2_code), 
    .status(status), 
    .control(control),    
    .num(ps2_num)
);

color_codes color_codes_inst(
    .num(cpu_out[5:0]), 
    .code(vga_code)
);

vga vga_inst(
    .clk(clk), 
    .rst_n(rst_n), 
    .code(vga_code), 
    .hsync(mnt[13]), 
    .vsync(mnt[12]), 
    .red(mnt[11:8]), 
    .green(mnt[7:4]), 
    .blue(mnt[3:0])
);

bcd bcd_inst0(
    .in(pc_out), 
    .ones(ones_pc),
    .tens(tens_pc)
);

bcd bcd_inst1(
    .in(sp_out), 
    .ones(ones_sp),
    .tens(tens_sp)
);


ssd ssd_inst0(
    .in(ones_pc), 
    .out(hex[6:0])
);

ssd ssd_inst1(
    .in(tens_pc), 
    .out(hex[13:7])
);

ssd ssd_inst2(
    .in(ones_sp), 
    .out(hex[20:14])
);

ssd ssd_inst3(
    .in(tens_sp), 
    .out(hex[27:21])
);


endmodule