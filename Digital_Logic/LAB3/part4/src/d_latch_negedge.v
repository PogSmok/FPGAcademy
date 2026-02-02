// A negative-edge triggered gated D latch
module d_latch_negedge (
	input 		Clk,
	input 		D,
	output reg 	Q
);

	always @ (negedge Clk) begin
		Q <= D;
	end

endmodule