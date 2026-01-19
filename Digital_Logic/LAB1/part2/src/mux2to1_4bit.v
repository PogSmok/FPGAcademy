/*
	4 bit wide 2 to 1 mutex
	Select 0 -> output x1, x2, x3, x4
	Select 1 -> output y1, y2, y3, y4
*/
module mux2to1_4bit (
	input s, // Select signal: 0 -> output x, 1 -> output y
	input [3:0] x, // Input 0
	input [3:0] y, // Input 1
	
	output [3:0] m // Output
);

	assign m = s ? y : x;
	
endmodule