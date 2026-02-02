module part3 (
	input  SW0,  // D
	input  SW1,  // CLK
	output LEDR0 // Q (slave)
);

	wire master_output;

	d_latch master(
		.Clk(~SW1),
		.D(SW0),
		.Q(master_output)
	);

	d_latch slave(
		.Clk(SW1),
		.D(master_output),
		.Q(LEDR0)
	);

endmodule