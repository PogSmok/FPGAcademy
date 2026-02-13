module counter #(
	parameter 		    n, // counter size 
	parameter  [n-1:0] k  // roll-over value
)(
	input              Clock,
	input              Pause, // active-low
	input 				 Load,  // asynchronous active-low load
	input      [n-1:0] D,
	output reg         Rollover = 0,
	output reg [n-1:0] Q = 0
);

always @(posedge Clock or negedge Load) begin
	if (!Load) begin
		Q <= (D >= k) ? 0 : D;
		Rollover <= 0;
	end else if (Pause) begin
		Q <= (Q == k-1) ? 0 : Q + 1;
		Rollover <= (Q == k-1);
	end
end

endmodule