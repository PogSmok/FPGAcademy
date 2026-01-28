/*
 * Checks if a 4-bit input is greater than 9.
 * Output is high (1) if input > 9, otherwise low (0).
 */
module comp_gt9 (
	input  [3:0] val,
	output       gt9 // 1 if val > 9, else 0
);
	
	assign gt9 = val[3] & (val[1] | val[2]);

endmodule