module part3 (
	input 		 KEY0, 	  // Pause button
	input 		 KEY1,     // Load SW into minutes
	input 		 CLOCK_50, // 50 MHz
	input	 [7:0] SW,
	output [0:6] HEX0, // Right-most display
	output [0:6] HEX1,
	output [0:6] HEX2, 
	output [0:6] HEX3,
	output [0:6] HEX4,
	output [0:6] HEX5 // Left-most display
);

	// 100 Hz clock generator
	wire signal_100hz;
	counter #(
		.n(19),
		.k(500_000)
	) u_c_100Hz (
		.Clock(CLOCK_50),
		.Pause(KEY0),
		.Load(1),
		.Rollover(signal_100hz),
	);
	
	// Centiseconds
	wire [3:0] centis;
	wire       centis_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_centis (
		.Clock(signal_100hz),
		.Pause(1),
		.Load(1),
		.Rollover(centis_rollover),
		.Q(centis)
	);
	
	// Deciseconds
	wire [3:0] decis;
	wire		  decis_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_decis (
		.Clock(centis_rollover),
		.Pause(1),
		.Load(1),
		.Rollover(decis_rollover),
		.Q(decis)
	);
	
	// Seconds
	wire [3:0] secs;
	wire       secs_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_secs (
		.Clock(decis_rollover),
		.Pause(1),
		.Load(1),
		.Rollover(secs_rollover),
		.Q(secs)
	);
	
	// Decaseconds
	wire [3:0] decas;
	wire       decas_rollover;
	counter #(
		.n(4),
		.k(6)
	) u_c_decas (
		.Clock(secs_rollover),
		.Pause(1),
		.Load(1),
		.Rollover(decas_rollover),
		.Q(decas)
	);
	
	// Minutes
	wire [3:0] mins;
	wire       mins_rollover;
	counter #(
		.n(4),
		.k(10)
	) u_c_mins (
		.Clock(decas_rollover),
		.Pause(1),
		.Load(KEY1),
		.D(SW[3:0]),
		.Rollover(mins_rollover),
		.Q(mins)
	);
	
	// Decaminutes
	wire [3:0] deca_mins;
	counter #(
		.n(4),
		.k(6)
	) u_c_deca_mins (
		.Clock(mins_rollover),
		.Pause(1),
		.Load(KEY1),
		.D(SW[7:4]),
		.Q(deca_mins)
	);
	
	bcd u_0 (.binary(centis), .seg(HEX0));
	bcd u_1 (.binary(decis), .seg(HEX1));
	bcd u_2 (.binary(secs), .seg(HEX2));
	bcd u_3 (.binary(decas), .seg(HEX3));
	bcd u_4 (.binary(mins), .seg(HEX4));
	bcd u_5 (.binary(deca_mins), .seg(HEX5));
	
endmodule