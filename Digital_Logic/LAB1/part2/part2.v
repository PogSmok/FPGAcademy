module part2 (
	input  [9:0] SW,  // SW[3:0]=x, SW[7:4]=y, SW[9]=select, SW[8]=unused
	output [9:0] LEDR // LEDR[3:0]=mux out, LEDR[9]=select indicator, LEDR[8:4]=unused
);

	// Define select
	wire s = SW[9];

	// Define output
	wire [3:0] m;
	
	// Create 4-bit 2 to 1 multiplexer
	mux2to1_4bit u_mux (
		.s(s),
		.x(SW[3:0]),
		.y(SW[7:4]),
		.m(m)
	);
	
	// Connect output to LEDS
	assign LEDR[3:0] = m; // Mux output
	assign LEDR[9] = s; // Select state
	assign LEDR[8:4] = 5'b0; // Turn off unused LEDs
	
endmodule