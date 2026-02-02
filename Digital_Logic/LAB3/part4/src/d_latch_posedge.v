// A positive-edge triggered gated D latch
module d_latch_posedge (
	input 		Clk,
	input 		D,
	output reg 	Q
);

	always @ (posedge Clk) begin
		Q <= D;
	end

endmodule