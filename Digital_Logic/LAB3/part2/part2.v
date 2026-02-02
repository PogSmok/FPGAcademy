module part2 (
	input  SW0,  // D
	input  SW1,  // Clk
	output LEDR0 // Q
);

	// Instantiate the gated D latch
	d_latch d1(
		.Clk(SW1),
		.D(SW0),
		.Q(LEDR0)
	);
	
endmodule
	
	