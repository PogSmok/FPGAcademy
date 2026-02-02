module part4 (
	input  Clk,
	input  D,
	output Qa,
	output Qb,
	output Qc
);

	d_latch d0 (.Clk(Clk), .D(D), .Q(Qa));
	
	d_latch_posedge d1 (.Clk(Clk), .D(D), .Q(Qb));

	d_latch_negedge d2 (.Clk(Clk), .D(D), .Q(Qc));

endmodule