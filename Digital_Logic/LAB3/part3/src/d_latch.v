// A gated D latch
module d_latch (
	input Clk,
	input D,
	output Q
);
	
	wire R, S_g, R_g, Qa, Qb /* synthesis keep */;
	
	assign S_g = ~(D & Clk);
	assign R   = ~D;
	assign R_g = ~(Clk & R);
	assign Qa  = ~(S_g & Qb);
	assign Qb  = ~(R_g & Qa);
	
	assign Q = Qa;
	
endmodule