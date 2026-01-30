/*
 * 4 bit wide 2 to 1 mutex
 * Select 0 -> output x0, x1, x2, x3
 *	Select 1 -> output y0, y1, y2, y3
 */
module mux_4bit_2to1 (
	input        s, // Select signal: 0 -> output x, 1 -> output y
	input  [3:0] x, // Input 0
	input  [3:0] y, // Input 1
	output [3:0] m  // Output
);

	assign m[0] = (~s & x[0]) | (s & y[0]);
	assign m[1] = (~s & x[1]) | (s & y[1]);
	assign m[2] = (~s & x[2]) | (s & y[2]);
	assign m[3] = (~s & x[3]) | (s & y[3]);

endmodule