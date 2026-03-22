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
    input [31:2] a,
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
    
    always @(*) begin
    
        y_temp <= {y_sign, {8{1'b1}}, 1'b0, {22{1'b1}}};
        {zero, inf, normal, subnormal, snan, qnan} <= 6'b000000;
        
        // a or b = qnan
        if ((aqnan | bqnan) == 1'b1) begin
            if(aqnan == 1'b1)
                y_temp <= aqnan;
            else 
                y_temp <= bqnan;               
            qnan <= 1'b1;
        end
        
        // a or b = snan
        else if ((asnan | bsnan) == 1'b1) begin
            if(asnan == 1'b1)
                y_temp <= asnan;
            else 
                y_temp <= bsnan;
                snan <= 1'b1;
        end
        
        // a or b = infinity
        else if ((ainf | binf) == 1'b1) begin
            if ((azero | bzero) == 1'b1) begin
                y_temp = {y_sign, {8{1'b1}}, 1'b1, 22'h000001}; // qnan and payload = 1 for infinity 
                qnan <= 1'b1;
            end
            else begin
                y_temp = {y_sign, {8{1'b1}}, {23{1'b1}}};
                inf <= 1'b1;
            end
        end
        
        // a or b = zero
        else if ((azero | bzero) == 1'b1) begin
            y_temp = {y_sign, {8{1'b0}}, {23{1'b0}}};
            zero <= 1'b1;
        end
    end

endmodule
