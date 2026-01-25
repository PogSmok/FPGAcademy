/*
	2 bit wide 4 to 1 mutex
	Select 00 -> output u1, u2
	Select 01 -> output v1, v2
	Select 10 -> output w1, w2
	Select 11 -> output x1, x2
*/
module mux4to1_2bit (
	input [1:0] s, // Select signal: 00 -> output u, 01 -> output v, 10 -> output w, 11 -> output x
	input [1:0] u, // Input 00
	input [1:0] v, // Input 01
	input [1:0] w, // Input 10
	input [1:0] x, // Input 11
	
	output [1:0] m // Output
);

	assign m = (s == 2'b00) ? u :
				  (s == 2'b01) ? v :
				  (s == 2'b10) ? w :
									  x;
	
endmodule