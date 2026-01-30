module part4 (
	input  [8:0] SW,    // SW[8]=carry in, SW[7:4]=X, SW[3:0]=Y
	output [0:6] HEX5,  // BCD display for X
	output [0:6] HEX3,  // BCD display for Y
	output [0:6] HEX1,  // Tens place of X+Y
	output [0:6] HEX0,  // Ones place of X+Y
	output       LEDR9  // Error indication (X or Y > 9)
);

	wire x_gt9;
	wire y_gt9;
	comp_gt9 u1_gt9(.val(SW[7:4]), .gt9(x_gt9));
	comp_gt9 u2_gt9(.val(SW[3:0]), .gt9(y_gt9));

	assign LEDR9 = x_gt9 | y_gt9; // Indicate addends are out of operational range

	wire [3:0] sum;
	wire       c_out;
	
	ripple_adder_4bit u1_ra(
		.a(SW[7:4]),
		.b(SW[3:0]),
		.c_in(SW[8]),
		.sum(sum),
		.c_out(c_out)
	);
	
	wire is_gt9;
	comp_gt9 u3_gt9(.val({c_out, sum}), .gt9(is_gt9));
	
	// Overflow 4-bits, so that BCD works correctly for sum > 9
	// 10 + 6 = 16 = 0 (on 4 bits)
	// 14 + 6 = 20 = 4 (on 4 bits)
	// etc.
	wire [3:0] complementary_sum;
	mux_4bit_2to1 u_mux(
		.s(is_gt9),
		.x(4'b0000),
		.y(4'b0110),
		.m(complementary_sum)
	);
	
	wire [3:0] corrected_sum;
	ripple_adder_4bit u2_ra(
		.a(sum),
		.b(complementary_sum),
		.c_in(1'b0),
		.sum(corrected_sum)
		// .c_out() unused
	);
	
	bcd u5_bcd(
		.binary(SW[7:4]),
		.seg(HEX5)
	);
	
	bcd u3_bcd(
		.binary(SW[3:0]),
		.seg(HEX3)
	);
	
	bcd u1_bcd(
		.binary({3'b0, is_gt9}),
		.seg(HEX1)
	);
	
	bcd u0_bcd(
		.binary(corrected_sum),
		.seg(HEX0)
	);

endmodule