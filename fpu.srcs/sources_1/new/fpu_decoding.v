`timescale 1ns / 1ps

module fpu_decoding(
    input [31:0] float,
   output zero, inf, normal, subnormal, snan, qnan
);

    wire exp0, exp1, mant0;
    
    assign exp1      = &float[30:23];
    assign exp0      = ~|float[30:23];
    assign mant0     = ~|float[22:0];
    
    assign zero      = exp0 & mant0;
    assign inf       = exp1 & mant0;
    assign normal    = ~exp0 & ~exp1;
    assign subnormal = exp0 & ~mant0;
    assign snan      = exp1 & ~mant0 & ~float[22];
    assign qnan      = exp1 & float[22];

endmodule

module fpu_mul(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] y,
    output reg zero, inf, normal, subnormal, snan, qnan
);
    wire azero, ainf, anormal, asubnormal, asnan, aqnan;
    wire bzero, binf, bnormal, bsubnormal, bsnan, bqnan;
    
    fpu_decoding inst1(.float(a), .zero(azero), .inf(ainf), .normal(anormal), .subnormal(asubnormal), .snan(asnan), .qnan(aqnan));
    fpu_decoding inst2(.float(b), .zero(bzero), .inf(binf), .normal(bnormal), .subnormal(bsubnormal), .snan(bsnan), .qnan(bqnan));
    
    reg [31:0] y_temp;
    reg y_sign;
    reg [23:0] asig;
    reg [23:0] bsig;
    reg signed [9:0] aexp;
    reg signed [9:0] bexp;
    reg [47:0] rawsig;
    reg signed [9:0] rawexp;
    reg [23:0] actual_prod_sig;
    reg signed [9:0] actual_prod_exp;
    reg [7:0] bias_prod_exp;
    integer shift;
    
    always @(*) begin
        y_sign = a[31] ^ b[31]; // sign of final product
        
        y_temp = {y_sign, {8{1'b1}}, 1'b0, {22{1'b1}}};
        {zero, inf, normal, subnormal, snan, qnan} = 6'b000000;
        
        // a or b = qnan
        if ((aqnan | bqnan) == 1'b1) begin
            y_temp = {1'b0, 8'hFF, 1'b1, 22'b0};              
            qnan = 1'b1;
        end
        
        // a or b = snan
        else if ((asnan | bsnan) == 1'b1) begin
            y_temp = {1'b0, 8'hFF, 1'b0, 22'b1};
            snan = 1'b1;
        end
        
        // a or b = infinity
        else if ((ainf | binf) == 1'b1) begin
            if ((azero | bzero) == 1'b1) begin
                y_temp = {y_sign, {8{1'b1}}, 1'b1, 22'h000001}; // qnan and payload = 1 for infinity 
                qnan = 1'b1;
            end
            else begin
                y_temp = {y_sign, {8{1'b1}}, {23{1'b0}}};
                inf = 1'b1;
            end
        end
        
        // a or b = zero
        else if ((azero | bzero) == 1'b1) begin
            y_temp = {y_sign, {8{1'b0}}, {23{1'b0}}};
            zero = 1'b1;
        end
        
        // a and b = normal
        asig = (asubnormal) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
        bsig = (bsubnormal) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};
        
        aexp = (asubnormal) ? -126 : (a[30:23] - 127);
        bexp = (bsubnormal) ? -126 : (b[30:23] - 127);
        
        rawsig = asig * bsig; // raw significand
        rawexp = aexp + bexp; // raw exponent
        
        // normalizing the significand 
        if (rawsig[47] == 1'b1) begin
            actual_prod_sig = rawsig[46:24]; // concat the significand value of product (for now I am not rounding the significand)
            actual_prod_exp = rawexp + 1; 
        end   
        else begin
            actual_prod_sig = rawsig[45:23];
            actual_prod_exp = rawexp;
        end
        
        if (actual_prod_exp < -149) begin // if the product is too small then zero flag = 1
            y_temp = {y_sign, {31{1'b0}}};
            zero = 1'b1;
        end
        
        else if (actual_prod_exp < -126) begin // if the product is subnormal then subnormal flag = 1
            shift = -126 - actual_prod_exp;
            actual_prod_sig = actual_prod_sig >> shift;
            y_temp = {y_sign, 8'h00, actual_prod_sig[22:0]};
            subnormal = 1'b1;
        end
        
        else if (actual_prod_exp > 127) begin // if the product is too large then infinity flag = 1
            y_temp = {y_sign, 8'hFF, {23{1'b0}}};
            inf = 1'b1;
        end
        
        else begin // if the product is normal then normal flag = 1
            bias_prod_exp = actual_prod_exp + 127;
            y_temp = {y_sign, bias_prod_exp[7:0], actual_prod_sig[22:0]}; 
            normal = 1'b1;
        end
        
        y = y_temp;
    end
endmodule
