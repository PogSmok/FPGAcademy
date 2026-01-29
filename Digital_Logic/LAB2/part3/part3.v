module part3(
input  [8:0] SW,   // SW[3:0]=num A, SW[7:4]=num B, SW[8]=carry in
output [4:0] LEDR // LEDR[3:0]=A+B, LEDR[4]=carry out
);
	
	wire c1_out;
	wire c2_out;
	wire c3_out;
	wire c4_out;
	
	full_adder u1_fa(
		.a(SW[0]),
		.b(SW[4]),
		.c_in(SW[8]),
		.sum(LEDR[0]),
		.c_out(c1_out)
	);
	
	full_adder u2_fa(
		.a(SW[1]),
		.b(SW[5]),
		.c_in(c1_out),
		.sum(LEDR[1]),
		.c_out(c2_out)
	);
	
	full_adder u3_fa(
		.a(SW[2]),
		.b(SW[6]),
		.c_in(c2_out),
		.sum(LEDR[2]),
		.c_out(c3_out)
	);

	full_adder u4_fa(
		.a(SW[3]),
		.b(SW[7]),
		.c_in(c3_out),
		.sum(LEDR[3]),
		.c_out(c4_out)
	);
	
	assign LEDR[4] = c4_out;

endmodule