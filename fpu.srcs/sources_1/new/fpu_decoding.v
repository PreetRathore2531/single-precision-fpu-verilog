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
    
);

    

endmodule
