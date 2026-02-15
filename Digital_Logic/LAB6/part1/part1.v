module part1 (
	input        KEY0, // Reset
	input 		 KEY1, // Clock
	input  [7:0] SW,   // A
	output [9:0] LEDR, // LEDR[7:0]=SUM, LEDR[8]=OVERFLOW, LEDR[9]=CARRY
	output [0:6] HEX0, HEX1, HEX2, HEX3 // HEX1-0=A, HEX3-2=SUM
);
	accumulator #(.n(8)) u_accum (
		.Clock(~KEY1),
		.Reset(KEY0),
		.A(SW),
		.carry(LEDR[9]),
		.overflow(LEDR[8]),
		.S(LEDR[7:0])
	);
	
	hex_decoder u_dec0 (
		.num(LEDR[3:0]),
		.seg(HEX0)
	);
	
	hex_decoder u_dec1 (
		.num(LEDR[7:4]),
		.seg(HEX1)
	);
		
	hex_decoder u_dec2 (
		.num(SW[3:0]),
		.seg(HEX2)
	);
	
	hex_decoder u_dec3 (
		.num(SW[7:4]),
		.seg(HEX3)
	);

endmodule