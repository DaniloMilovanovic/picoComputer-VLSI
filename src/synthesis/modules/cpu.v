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

localparam 
    MOV = 4'b0000, 
    ADD = 4'b0001, 
    SUB = 4'b0010, 
    MUL = 4'b0011, 
    DIV = 4'b0100, 
    IN = 4'b0111,
    OUT = 4'b1000,
    STOP = 4'b1111;/*OVDE
    JSR = 4'b0101,
    RTS = 4'b1110,
    BEQ = 4'b1010*/

reg [2:0] alu_oc;
reg [DATA_WIDTH - 1:0] alu_a, alu_b; 
wire [DATA_WIDTH - 1:0] alu_f;
alu #(.DATA_WIDTH(DATA_WIDTH)) ALU(.oc(alu_oc), .a(alu_a), .b(alu_b), .f(alu_f));

reg pc_cl, pc_ld, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il;
reg [ADDR_WIDTH - 1:0] pc_in;
wire [ADDR_WIDTH - 1:0] pc_out;
register #(.DATA_WIDTH(ADDR_WIDTH)) PC(
    .clk(clk), 
    .rst_n(rst_n), 
    .cl(pc_cl), 
    .ld(pc_ld), 
    .in(pc_in), 
    .inc(pc_inc), 
    .dec(pc_dec), 
    .sr(pc_sr), 
    .ir(pc_ir), 
    .sl(pc_sl), 
    .il(pc_il), 
    .out(pc_out)
); 

reg sp_cl, sp_ld, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il;
reg [ADDR_WIDTH - 1:0] sp_in;
wire [ADDR_WIDTH - 1:0] sp_out;
register #(.DATA_WIDTH(ADDR_WIDTH)) SP(
    .clk(clk), 
    .rst_n(rst_n), 
    .cl(sp_cl), 
    .ld(sp_ld), 
    .in(sp_in), 
    .inc(sp_inc), 
    .dec(sp_dec), 
    .sr(sp_sr), 
    .ir(sp_ir), 
    .sl(sp_sl), 
    .il(sp_il), 
    .out(sp_out)
);

reg ir_cl, ir_ld, ir_inc, ir_dec, ir_sr, ir_ir, ir_sl, ir_il;
reg [2 * DATA_WIDTH - 1:0] ir_in;
wire [2 * DATA_WIDTH - 1:0] ir_out;
register #(.DATA_WIDTH(2 * DATA_WIDTH)) IR(
    .clk(clk), 
    .rst_n(rst_n), 
    .cl(ir_cl), 
    .ld(ir_ld), 
    .in(ir_in), 
    .inc(ir_inc), 
    .dec(ir_dec), 
    .sr(ir_sr), 
    .ir(ir_ir), 
    .sl(ir_sl), 
    .il(ir_il), 
    .out(ir_out)
);

reg mar_cl, mar_ld, mar_inc, mar_dec, mar_sr, mar_ir, mar_sl, mar_il;
reg [ADDR_WIDTH - 1:0] mar_in;
wire [ADDR_WIDTH - 1:0] mar_out;
register #(.DATA_WIDTH(ADDR_WIDTH)) MAR(
    .clk(clk), 
    .rst_n(rst_n), 
    .cl(mar_cl), 
    .ld(mar_ld), 
    .in(mar_in), 
    .inc(mar_inc), 
    .dec(mar_dec), 
    .sr(mar_sr), 
    .ir(mar_ir), 
    .sl(mar_sl), 
    .il(mar_il), 
    .out(mar_out)
);

reg mdr_cl, mdr_ld, mdr_inc, mdr_dec, mdr_sr, mdr_ir, mdr_sl, mdr_il;
reg [DATA_WIDTH - 1:0] mdr_in;
wire [DATA_WIDTH - 1:0] mdr_out;
register #(.DATA_WIDTH(DATA_WIDTH)) MDR(
    .clk(clk), 
    .rst_n(rst_n), 
    .cl(mdr_cl), 
    .ld(mdr_ld), 
    .in(mdr_in), 
    .inc(mdr_inc), 
    .dec(mdr_dec), 
    .sr(mdr_sr), 
    .ir(mdr_ir), 
    .sl(mdr_sl), 
    .il(mdr_il), 
    .out(mdr_out)
);

reg a_cl, a_ld, a_inc, a_dec, a_sr, a_ir, a_sl, a_il;
reg [DATA_WIDTH - 1:0] a_in;
wire [DATA_WIDTH - 1:0] a_out;
register #(.DATA_WIDTH(DATA_WIDTH)) A(
    .clk(clk), 
    .rst_n(rst_n), 
    .cl(a_cl), 
    .ld(a_ld), 
    .in(a_in), 
    .inc(a_inc), 
    .dec(a_dec), 
    .sr(a_sr), 
    .ir(a_ir), 
    .sl(a_sl), 
    .il(a_il), 
    .out(a_out)
);

reg [9:0] state_reg, state_next;

reg we_reg, we_next;
reg [DATA_WIDTH - 1:0] out_reg, out_next;

assign we = we_reg;
assign addr = mar_out;
assign data = mdr_out;
assign out = out_reg;
assign pc = pc_out;
assign sp = sp_out;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_reg <= 1'b0;
        state_reg <= {10{1'b0}};
        we_reg <= 1'b0;
        out_reg <= {(DATA_WIDTH - 1){1'b0}};
    end
    else begin
        state_reg <= state_next;
        we_reg <= we_next;
        out_reg <= out_next;
    end
end

always @(*) begin
    state_next = state_reg;
    we_next = 1'b0;
    out_next = out_reg;

    pc_cl = 1'b0;
    pc_ld = 1'b0;
    pc_inc = 1'b0;
    pc_dec = 1'b0;
    pc_sr = 1'b0;
    pc_ir = 1'b0;
    pc_sl = 1'b0;
    pc_il = 1'b0;
    pc_in = {(ADDR_WIDTH){1'b0}}; //FIX THIS!!!

    sp_cl = 1'b0;
    sp_ld = 1'b0;
    sp_inc = 1'b0;
    sp_dec = 1'b0;
    sp_sr = 1'b0;
    sp_ir = 1'b0;
    sp_sl = 1'b0;
    sp_il = 1'b0;
    sp_in = {(ADDR_WIDTH){1'b0}};

    ir_cl = 1'b0;
    ir_ld = 1'b0;
    ir_inc = 1'b0;
    ir_dec = 1'b0;
    ir_sr = 1'b0;
    ir_ir = 1'b0;
    ir_sl = 1'b0;
    ir_il = 1'b0;
    ir_in = {(2 * DATA_WIDTH){1'b0}};

    mar_cl = 1'b0;
    mar_ld = 1'b0;
    mar_inc = 1'b0;
    mar_dec = 1'b0;
    mar_sr = 1'b0;
    mar_ir = 1'b0;
    mar_sl = 1'b0;
    mar_il = 1'b0;
    mar_in =  {(ADDR_WIDTH){1'b0}};

    mdr_cl = 1'b0;
    mdr_ld = 1'b0;
    mdr_inc = 1'b0;
    mdr_dec = 1'b0;
    mdr_sr = 1'b0;
    mdr_ir = 1'b0;
    mdr_sl = 1'b0;
    mdr_il = 1'b0;
    mdr_in =  {(DATA_WIDTH){1'b0}};

    a_cl = 1'b0;
    a_ld = 1'b0;
    a_inc = 1'b0;
    a_dec = 1'b0;
    a_sr = 1'b0;
    a_ir = 1'b0;
    a_sl = 1'b0;
    a_il = 1'b0;
    a_in =  {(DATA_WIDTH){1'b0}};

    alu_oc = 3'b0;
    alu_a = {(DATA_WIDTH - 1){1'b0}};
    alu_b = {(DATA_WIDTH - 1){1'b0}};

    case (state_reg)
        10'd0: begin //initialize registers
            we_next = 1'b0;
            out_next = out_reg;
            
            pc_in = 6'd8; // pc start position on pico computer
            pc_ld = 1'b1;

            sp_in = {(ADDR_WIDTH){1'b1}};; // sp points to the last available address
            sp_ld = 1'b1;

            state_next = 10'd1;
        end
        //IF phase
        10'd1: begin // MAR <= PC; PC = PC + 1;
            mar_ld = 1'b1;
            mar_in = pc_out;

            pc_inc = 1'b1;

            state_next = 10'd2;
        end 

        10'd2: begin //MDR <= MEM[MAR];
            mdr_ld = 1'b1;
            mdr_in = mem;
            
            state_next = 10'd3;
        end

        10'd3: begin // IR[15:0] <= MDR;
            ir_in = {{DATA_WIDTH{1'b0}}, mdr_out};
            ir_ld = 1'b1;
            state_next = 10'd4;
        end //If there were instructions that needed IR[15:0], we would add it here
        // Get the first operand 15:12  11:08  07:04  03:00
        
        10'd4: begin 
            case (ir_out[15:12])
                MOV: state_next = 10'd5;
                ADD: state_next = 10'd5;
                SUB: state_next = 10'd5;
                MUL: begin 
                    if(ir_out[3:0] == 4'h0)
                        state_next = 10'd1;
                    else
                        state_next = 10'd5;
                end
                DIV: state_next = 10'd5;
                IN: state_next = 10'd15;
                OUT: state_next = 10'd16;
                STOP: state_next = 10'd21;/*OVDE
                JSR: state_next = 10'd38;
                RTS: state_next = 10'd40;
                BEQ: state_next = 10'd44;*/
                default: 
                    state_next = 10'd63;//error state
            endcase
        end
        //MOV, ADD, SUB, MUL, DIV
        5'd5: begin //MAR <= y2..0
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[6:4]}; //y2..0
            state_next = 10'd6;
        end

        10'd6: begin // MDR <= MEM[MAR];
            mdr_ld = 1'b1; 
            mdr_in = mem;

            if(ir_out[7]) begin //regind
                state_next = 10'd7;
            end
            else begin //regdir
                state_next = 10'd9;
            end
        end

        10'd7: begin // MAR <= MEM[y2..0];
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1: 0];
            state_next = 10'd8;
        end

        10'd8: begin // MDR <= MEM[MEM[y2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd9;
        end

        10'd9: begin // A <= MDR;
            a_ld = 1'b1;
            a_in = mdr_out;
            if(ir_out[15:12] == MOV) //2 operand instructions
                state_next = 10'd34;
            else
                state_next = 10'd10;
        end

        10'd10: begin //MAR <= z2..0;
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[2:0]}; //z2..0
            state_next = 10'd11;
        end

        10'd11: begin //MDR <= MEM[z2..0];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            if(ir_out[3]) begin //regind
                state_next = 10'd12;
            end
            else begin //regdir
                state_next = 10'd14;
            end
        end

        10'd12: begin // MAR <= MEM[z2..0]
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1: 0];
            state_next = 10'd13;
        end

        10'd13: begin // MDR <= MEM[MEM[z2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd14;
        end

        10'd14: begin 
            alu_a = a_out;
            alu_b = mdr_out;
            alu_oc = ir_out[14:12] - 1'b1;
            a_in = alu_f;
            a_ld = 1'b1;

            state_next = 10'd34;
        end

        //IN operation
        //Load in into accumulator
        10'd15: begin
            a_ld = 1'b1;
            a_in = in;
            state_next = 10'd34;
        end

        //OUT operation
        //Load the x2..0 operand into the accumulator
        10'd16: begin //MAR <= x2..0
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[10:8]}; //x2..0
            state_next = 10'd17;
        end

        10'd17: begin // MDR <= MEM[MAR];
            mdr_ld = 1'b1; 
            mdr_in = mem;

            if(ir_out[11]) begin //regind
                state_next = 10'd18;
            end
            else begin //regdir
                state_next = 10'd20;
            end
        end

        10'd18: begin // MAR <= MEM[x2..0];
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1:0];
            state_next = 10'd19;
        end

        10'd19: begin // MDR <= MEM[MEM[x2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd20;
        end

        10'd20: begin // OUT <= MDR;
            out_next = mdr_out;
            state_next = 10'd1;
        end

        //STOP operation
        10'd21: begin //MAR <= x2..0
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[10:8]}; //x2..0
            state_next = 10'd22;
        end

        10'd22: begin // MDR <= MEM[MAR];
            mdr_ld = 1'b1; 
            mdr_in = mem;

            if(ir_out[11]) begin //regind
                state_next = 10'd23;
            end
            else begin //regdir
                state_next = 10'd25;
            end
        end

        10'd23: begin // MAR <= MEM[x2..0];
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1:0];
            state_next = 10'd24;
        end

        10'd24: begin // MDR <= MEM[MEM[x2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd25;
        end

        10'd25: begin // OUT <= MDR;
            out_next = mdr_out;
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[6:4]}; //y2..0
            state_next = 10'd26;
        end

        10'd26: begin // MDR <= MEM[MAR];
            mdr_ld = 1'b1; 
            mdr_in = mem;

            if(ir_out[7]) begin //regind
                state_next = 10'd27;
            end
            else begin //regdir
                state_next = 10'd29;
            end
        end

        10'd27: begin // MAR <= MEM[y2..0];
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1: 0];
            state_next = 10'd28;
        end

        10'd28: begin // MDR <= MEM[MEM[y2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd29;
        end

        10'd29: begin // OUT <= MDR;
            out_next = mdr_out;
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[2:0]}; //z2..0
            state_next = 10'd30;
        end

        10'd30: begin //MDR <= MEM[z2..0];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            if(ir_out[3]) begin //regind
                state_next = 10'd31;
            end
            else begin //regdir
                state_next = 10'd33;
            end
        end

        10'd31: begin // MAR <= MEM[z2..0]
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1:0];
            state_next = 10'd32;
        end

        10'd32: begin // MDR <= MEM[MEM[z2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd33;
        end

        10'd33: begin // OUT <= MDR;
            out_next = mdr_out;
            state_next = 10'd63;
        end

        
        // LOAD ALU into first operand
        10'd34: begin //MAR <= x2..0 
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[10:8]};
            if(ir_out[11])
                state_next = 10'd35;
            else
                state_next = 10'd37;
        end

        10'd35: begin //MDR <= MEM[MAR];
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = 10'd36;
        end

        10'd36: begin //MAR <= MEM[x2..0];
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1: 0];
            state_next = 10'd37;
        end

        10'd37: begin // MDR <= ACC;
            mdr_ld = 1'b1;
            mdr_in = a_out;
            we_next = 1'b1;
            state_next = 10'd1;
        end
        /*OVDE
        10'd38: begin //JSR
            mar_in = sp_out;
            sp_dec = 1'b1;
            mar_ld = 1'b1;
            mdr_in = pc_out;
            mdr_ld = 1'b1;
            we_next = 1'b1;
            state_next = 10'd39;
        end

        10'd39: begin //JSR
            pc_in = {{ADDR_WIDTH - 6{1'b0}}, ir_out[5:0]};
            pc_ld = 1'b1;
            state_next = 10'd1;
        end

        10'd40: begin //RTS
            sp_inc = 1'b1;
            state_next = 10'd41;
        end

        10'd41: begin //RTS
            mar_ld = 1'b1;
            mar_in = sp_out;
            state_next = 10'd42;
        end
        
        10'd42: begin//RTS
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = 10'd43;
        end

        10'd43: begin//RTS
            pc_in = mdr_out;
            pc_ld = 1'b1;
            state_next = 10'd1;
        end

        10'd44: begin //BEQ
            mar_ld = 1'b1;
            mar_in = pc_out;
            pc_inc = 1'b1;
            state_next = 10'd45;
        end
        
        10'd45: begin
            mdr_ld = 1'b1;
            mdr_in = mem;
            
            state_next = 10'd46;
        end

        10'd46: begin // IR[31:16] <= MDR;
            ir_in = {mdr_out, ir_out[15:0]};
            ir_ld = 1'b1;
            state_next = 10'd47;
        end

        10'd47: begin //MAR <= x2..0
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[10:8]};
            state_next = 10'd48;
        end

        10'd48: begin // MDR <= MEM[MAR];
            mdr_ld = 1'b1; 
            mdr_in = mem;

            if(ir_out[11]) begin //regind
                state_next = 10'd49;
            end
            else begin //regdir
                state_next = 10'd51;
            end
        end

        10'd49: begin // MAR <= MEM[x2..0];
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1: 0];
            state_next = 10'd50;
        end

        10'd50: begin // MDR <= MEM[MEM[x2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd51;
        end

        10'd51: begin // A <= MDR;
            a_ld = 1'b1;
            a_in = mdr_out;
            state_next = 10'd52;
        end

        10'd52: begin //MAR <= y2..0;
            mar_ld = 1'b1;
            mar_in = {{ADDR_WIDTH - 3{1'b0}}, ir_out[6:4]}; //y2..0
            state_next = 10'd53;
        end

        10'd53: begin //MDR <= MEM[y2..0];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            if(ir_out[7]) begin //regind
                state_next = 10'd54;
            end
            else begin //regdir
                state_next = 10'd56;
            end
        end

        10'd54: begin // MAR <= MEM[y2..0]
            mar_ld = 1'b1;
            mar_in = mdr_out[ADDR_WIDTH - 1: 0];
            state_next = 10'd55;
        end

        10'd55: begin // MDR <= MEM[MEM[y2..0]];
            mdr_ld = 1'b1; 
            mdr_in = mem;
            state_next = 10'd56;
        end

        10'd56: begin 
            if(a_out == mdr_out) begin
                pc_in = ir_out[31:16];
                pc_ld = 1'b1;
            end
            if(a_out == 0) begin
                if(a_)
            end
            state_next = 10'd1;
        end
        
        10'd38: begin
        
        end*/
        
        10'd63: begin
            state_next = 10'd63;
        end
        default:
            state_next = 10'd63;
    endcase
end

endmodule