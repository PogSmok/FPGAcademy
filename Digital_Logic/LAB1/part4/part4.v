module part4(
	input  [1:0] SW,  // code
	output [0:6] HEX0 // 7-segment display
);

   // Instantiate 7-segment decoder
	decoder_7seg u_dec (
		.code(SW[1:0]),
		.segments(HEX0)
	);
	
	
endmodule