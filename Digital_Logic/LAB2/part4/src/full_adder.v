/*
 * Performs a+b+c_in
 * Returns sum and carry
 */
module full_adder(
	input  a,
	input  b,
	input  c_in, // Carry in
	output sum,  
	output c_out // Carry out
);

	assign sum = (~a&~b&c_in) | (~a&b&~c_in) | (a&~b&~c_in) | (a&b&c_in);
	assign c_out = (a&b) | (a&c_in) | (b&c_in);

endmodule