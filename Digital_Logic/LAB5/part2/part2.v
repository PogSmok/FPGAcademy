module part2 (
	input 		 KEY0, 	  // Reset
	input 		 CLOCK_50, // 50 MHz
	output [0:6] HEX0, // Right-most display
	output [0:6] HEX1,
	output [0:6] HEX2  // Left-most display
);
	
	
	// 1 Hz clock generator
	wire signal_1hz;
	counter #(
		.n(26),
		.k(50_000_000)
	) u_c_1Hz (
		.Clock(CLOCK_50),
		.Reset_n(KEY0),
		.Rollover(signal_1hz)
	);
	
	// Ones digit
	wire [3:0] ones;
	wire       ones_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_ones (
		.Clock(signal_1hz),
		.Reset_n(KEY0),
		.Rollover(ones_rollover),
		.Q(ones)
	);
	
	// Tens digit
	wire [3:0] tens;
	wire       tens_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_tens (
		.Clock(ones_rollover),
		.Reset_n(KEY0),
		.Rollover(tens_rollover),
		.Q(tens)
	);
	
	// Hundreds digit
	wire [3:0] hundreds;
	wire       hundreds_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_hundreds (
		.Clock(tens_rollover),
		.Reset_n(KEY0),
		.Q(hundreds)
	);
	
	bcd u_0 (.binary(ones), .seg(HEX0));
	bcd u_1 (.binary(tens), .seg(HEX1));
	bcd u_2 (.binary(hundreds), .seg(HEX2));
	
endmodule