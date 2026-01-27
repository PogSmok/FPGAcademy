module part1(
	input  [7:0] SW,   // SW[3:0]=HEX0, SW[7:4]=HEX1
	output [0:6] HEX0, // 7-segment display for SW[3:0]
	output [0:6] HEX1  // 7-segment display for SW[7:4]
);
	
   // Instantiate BCD decoder for HEX0
	bcd ubcd0(.binary(SW[3:0]), .seg(HEX0));
	
   // Instantiate BCD decoder for HEX1
	bcd ubcd1(.binary(SW[7:4]), .seg(HEX1));

endmodule