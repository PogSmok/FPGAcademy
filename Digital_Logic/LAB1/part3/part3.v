module part3 (
	input  [9:0] SW,  // SW[1:0]=u, SW[3:2]=v, SW[5:4]=w, SW[7:6]=x SW[9:8]=select
	output [9:0] LEDR // LEDR[1:0]=mux out, LEDR[9:2]=unused
);
	// Define output
	wire [1:0] m;

	// Create 2-bit 4 to 1 multiplexer
	mux4to1_2bit u_mux (
		.s(SW[9:8]),
		.u(SW[1:0]),
		.v(SW[3:2]),
		.w(SW[5:4]),
		.x(SW[7:6]),
		.m(m)
	);
	
	// Display mux output
	assign LEDR[1:0] = m;
	
	// Turn off unused LEDs
	assign LEDR[9:2] = 8'b0;

endmodule