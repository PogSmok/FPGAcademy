// A gated D latch
module d_latch (
	input 	  Clk,
	input 	  D,
	output reg Q
);

	always @ (*) begin
		if(Clk) Q = D;
	end

endmodule