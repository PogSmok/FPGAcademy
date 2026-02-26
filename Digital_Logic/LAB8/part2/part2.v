module part2 (
	input  [9:0] SW,   // SW[9]=wren, SW[8:4]=address, SW[3:0]=data
	input        KEY0, // clock
	output [0:6] HEX0,
	output [0:6] HEX2,
	output [0:6] HEX4,
	output [0:6] HEX5
);
	wire [3:0] q;

	ram32x4 u_ram(
    .address(SW[8:4]),
    .clock(KEY0),
    .data(SW[3:0]),
    .wren(SW[9]),
    .q(q)
	);
	
	hex_decoder h0 (
		.num(q),
		.seg(HEX0)
	);
	
	hex_decoder h2 (
		.num(SW[3:0]),
		.seg(HEX2)
	);
	
	hex_decoder h4 (
		.num(SW[7:4]),
		.seg(HEX4)
	);
	
	hex_decoder h5 (
		.num({3'b0, SW[8]}),
		.seg(HEX5)
	);

endmodule