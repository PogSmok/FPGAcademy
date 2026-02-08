/*	
	0000 -> blank
	0001 -> blank
	0010 -> blank
	0011 -> 'd'
	0100 -> 'E'
	0101 -> '1'
*/
module decoder_7seg (
	input  [3:0] code,    // 4-bit input code
	output [6:0] segments // 7-segment output (MSB = a, LSB = g)
);
	
	wire [2:0] valid_code;
	
	assign valid_code = code > 5 ? code - 6 : code;

	assign segments = (valid_code == 3'b000) ? 7'b1111111 : // blank
							(valid_code == 3'b001) ? 7'b1111111 : // blank
							(valid_code == 3'b010) ? 7'b1111111 : // blank
							(valid_code == 3'b011) ? 7'b1000010 : // 'd'
							(valid_code == 3'b100) ? 7'b0110000 : // 'E'
															 7'b1001111 ; // '1'
													
endmodule