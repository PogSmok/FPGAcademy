/*	
	00 -> blank
	01 -> 'd'
	10 -> 'E'
	11 -> '1'
*/
module decoder_7seg (
	input  [1:0] code,    // 2-bit input code
	output [6:0] segments // 7-segment output (MSB = a, LSB = g)
);

	assign segments = (code == 2'b00) ? 7'b1111111 :  // blank
							(code == 2'b01) ? 7'b1000010 : // 'd'
							(code == 2'b10) ? 7'b0110000 : // 'E'
													7'b1001111 ; // '1'
													
endmodule