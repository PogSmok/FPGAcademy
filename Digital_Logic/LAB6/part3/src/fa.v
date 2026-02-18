module fa (
	input  A,
	input  B,
	input  C_in,
	output S,
	output C_out
);

	assign {C_out, S} = A + B + C_in;

endmodule