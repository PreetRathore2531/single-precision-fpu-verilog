`timescale 1ns / 1ps

module tb_fpu_mul;

reg [31:0] a, b;
wire [31:0] y;
wire zero, inf, normal, subnormal, snan, qnan;

fpu_mul uut (
    .a(a),
    .b(b),
    .y(y),
    .zero(zero),
    .inf(inf),
    .normal(normal),
    .subnormal(subnormal),
    .snan(snan),
    .qnan(qnan)
);

initial begin
    $display("Starting Test...");

    // 1. Normal × Normal
    a = 32'h40400000; // 3.0
    b = 32'h40000000; // 2.0
    #10;

    // 2. Zero × Number
    a = 32'h00000000;
    b = 32'h40400000;
    #10;

    // 3. Infinity × Number
    a = 32'h7F800000;
    b = 32'h40000000;
    #10;

    // 4. Infinity × Zero ? NaN
    a = 32'h7F800000;
    b = 32'h00000000;
    #10;

    // 5. Subnormal × Normal
    a = 32'h00000001; // smallest subnormal
    b = 32'h3F800000; // 1.0
    #10;

    // 6. Overflow ? Infinity
    a = 32'h7F7FFFFF; // max float
    b = 32'h40000000; // ×2
    #10;

    // 7. Underflow ? Zero
    a = 32'h00800000; // smallest normal
    b = 32'h00800000;
    #10;

    // 8. NaN input
    a = 32'h7FC00000;
    b = 32'h40000000;
    #10;
    
    $finish;
    $monitor("a=%h b=%h y=%h normal=%b subnormal=%b zero=%b inf=%b", a,b,y,normal,subnormal,zero,inf);
end

endmodule
