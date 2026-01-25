/*
	Decodes code into 7-segment display value
	00 -> 'd'
	01 -> 'E'
	10 -> '1'
	00 -> blank
*/
module decoder_7seg (
	input  [1:0] code, // 2-bit input code
	output [6:0] segments // 7-segment output (MSB = a, LSB = g)
);

	assign segments = (code == 2'b00) ? 7'b1000010 : // 'd'
							(code == 2'b01) ? 7'b0110000 : // 'E'
							(code == 2'b10) ? 7'b1001111 : // '1'
													7'b1111111;  // blank

endmodule