module part1 (
	input        KEY0, // Reset (neg edge)
	input        KEY1, // Clk
	output [4:0] LEDR, // Counter
	output 		 LEDR9 // Rollover
);

	counter #(
		.n(5),
		.k(20)
	) u_c1 (
		.Clock(KEY1),
		.Reset_n(KEY0),
		.Rollover(LEDR9),
		.Q(LEDR)
	);

endmodule