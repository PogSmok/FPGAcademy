module part5 (
	input  [9:0] SW,   // SW[1:0]=code for 'd', SW[3:2]=code for 'E', SW[5:4]=code for '1', SW[7:6]=code for blank, SW[9:8]=pattern select
	output [9:0] LEDR, // Red LEDs displaying state of SW
	output [0:6] HEX0, // Right-most 7_segment display
	output [0:6] HEX1,
	output [0:6] HEX2,
	output [0:6] HEX3  // Left-most 7_segment display
);
	// Display state of SW on red LEDs
	assign LEDR = SW;

	// Define multilpexer outputs
	wire [1:0] m [3:0];
	
	// ---------------- HEX0 ----------------
	// Instantiate 2-bit 4 to 1 multiplexer for HEX0
	mux4to1_2bit u_mux0 (
		.s(SW[9:8]),
		.u(SW[7:6]),
		.v(SW[1:0]),
		.w(SW[3:2]),
		.x(SW[5:4]),
		.m(m[0])
	);
	
	// Instantiate 7-segment decoder for HEX0
	decoder_7seg u_dec0 (
		.code(m[0]),
		.segments(HEX0)
	);
	
	// ---------------- HEX1 ----------------
	// Instantiate 2-bit 4 to 1 multiplexer for HEX1
	mux4to1_2bit u_mux1 (
		.s(SW[9:8]),
		.u(SW[5:4]),
		.v(SW[7:6]),
		.w(SW[1:0]),
		.x(SW[3:2]),
		.m(m[1])
	);
	
	// Instantiate 7-segment decoder for HEX1
	decoder_7seg u_dec1 (
		.code(m[1]),
		.segments(HEX1)
	);
	
	// ---------------- HEX2 ----------------
	// Instantiate 2-bit 4 to 1 multiplexer for HEX2
	mux4to1_2bit u_mux2 (
		.s(SW[9:8]),
		.u(SW[3:2]),
		.v(SW[5:4]),
		.w(SW[7:6]),
		.x(SW[1:0]),
		.m(m[2])
	);
	
	// Instantiate 7-segment decoder for HEX2
	decoder_7seg u_dec2 (
		.code(m[2]),
		.segments(HEX2)
	);
	
	// ---------------- HEX3 ----------------
	// Instantiate 2-bit 4 to 1 multiplexer for HEX3
	mux4to1_2bit u_mux3 (
		.s(SW[9:8]),
		.u(SW[1:0]),
		.v(SW[3:2]),
		.w(SW[5:4]),
		.x(SW[7:6]),
		.m(m[3])
	);
	
	// Instantiate 7-segment decoder for HEX3
	decoder_7seg u_dec3 (
		.code(m[3]),
		.segments(HEX3)
	);

endmodule