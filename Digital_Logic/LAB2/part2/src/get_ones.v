/*
 * Returns digit at ones place in 10base representation of num
 * num must be greater than 9
 */
module get_ones (
	input  [3:0] num,
	output [3:0] ones
);

	assign ones[3] = 0;
	assign ones[2] = num[2] & num[1];
	assign ones[1] = num[2] & ~num[1];
	assign ones[0] = num[0];

endmodule