module top;
    
    reg [2:0] top_oc;
    reg [3:0] top_a, top_b, top_in;
    wire [3:0] top_f, top_out;
    reg top_clk, top_rst_n, top_cl, top_ld, top_inc, top_dec, top_sr, top_ir, top_sl, top_il;

    integer ind;
    reg test_alu, test_reg;

    alu inst0(.oc(top_oc), .a(top_a), .b(top_b), .f(top_f));
    register inst2(.clk(top_clk), .rst_n(top_rst_n), .cl(top_cl), .ld(top_ld), .in(top_in), .inc(top_inc), .dec(top_dec), .sr(top_sr), .ir(top_ir), .sl(top_sl), .il(top_il), .out(top_out));
    
    initial begin
        
        top_clk = 1'b0;
        top_oc = 3'bxxx;

        top_a = 4'hx;
        top_b = 4'hx;
        top_in = 4'hx;

        top_cl = 1'b0;
        top_ld = 1'b0;
        top_inc = 1'b0;
        top_dec = 1'b0;
        top_rst_n = 1'b0;
        top_sr = 1'b0;
        top_ir = 1'b0;
        top_sl = 1'b0;
        top_il = 1'b0;

        test_reg = 1'b0;
        test_alu = 1'b0;

        
        #10;
        // ALU arithmetic test
        $display("Start of the ALU arithmetic unit test.\n");

        test_alu = 1'b1;

        for (ind = 0; ind < 2**10 ; ind = ind + 1) begin
            {top_oc, top_a, top_b} = ind;
            #10;
        end

        test_alu = 1'b0;
        $stop;

        //ALU logical test
        $display("Start of the ALU logical unit test.\n");

        test_alu = 1'b1;

        for (ind = 2**10; ind < 2**11; ind = ind + 1) begin
            {top_oc, top_a, top_b} = ind;
            #10;
        end

        test_alu = 1'b0;
        $stop;
        
        //Register test
        $display("Start of the Refister unit test.\n");

        test_reg = 1'b1;

        for(ind = 0; ind < 1000; ind = ind + 1) begin
            {top_rst_n, top_cl, top_ld, top_inc, top_dec, top_sr, top_ir, top_sl, top_il, top_in} =  $random & 13'h1FFF;
            #10;
        end

        test_reg = 1'b0;
        $finish;

    end

    //Display for the ALU device
    always @(top_oc, top_a, top_b) begin
        if(test_alu) begin
            #0 $display("Vreme: %4d, Input oc: %b, Input a: %b, Input b: %b, Output: %b", $time, top_oc, top_a, top_b, top_f);
        end
    end

    //Display for the Register device
    always @(top_out) begin
        if(test_reg) begin
            #0 $display("Time: %4d, Input >> cl: %b, ld: %b, in: %b, inc: %b, dec: %b, sr: %b, ir: %b, sl: %b, il %b, Output >> out: %b",
            $time, top_cl, top_ld, top_in, top_inc, top_dec, top_sr, top_ir, top_sl, top_il, top_out);
        end
    end

    always  #5 top_clk = ~top_clk;

endmodule