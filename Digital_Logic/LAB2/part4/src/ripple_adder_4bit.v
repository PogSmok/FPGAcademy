/*
 * Performs a+b+c_in
 * Returns sum and carry
 */
module ripple_adder_4bit(
	input  [3:0] a,
	input  [3:0] b,
	input        c_in, // Carry in
	output [3:0] sum,  
	output       c_out // Carry out
);

	wire [3:0] ci_out; // carry out of individual full adders
	
	full_adder u1_fa(
		.a(a[0]),
		.b(b[0]),
		.c_in(c_in),
		.sum(sum[0]),
		.c_out(ci_out[0])
	);
	
	full_adder u2_fa(
		.a(a[1]),
		.b(b[1]),
		.c_in(ci_out[0]),
		.sum(sum[1]),
		.c_out(ci_out[1])
	);
	
	full_adder u3_fa(
		.a(a[2]),
		.b(b[2]),
		.c_in(ci_out[1]),
		.sum(sum[2]),
		.c_out(ci_out[2])
	);

	full_adder u4_fa(
		.a(a[3]),
		.b(b[3]),
		.c_in(ci_out[2]),
		.sum(sum[3]),
		.c_out(ci_out[3])
	);
	
	assign c_out = ci_out[3];
	
endmodule