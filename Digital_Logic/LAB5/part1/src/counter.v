module counter #(
	parameter 		    n, // counter size 
	parameter  [n-1:0] k  // roll-over value
)(
	input 			    Clock,
	input 			    Reset_n, // Active low asynchronous negative edge reset
	output    			 Rollover,
	output reg [n-1:0] Q
);
	
	assign Rollover = (Q == k-1);
	
	always @(posedge Clock or negedge Reset_n) begin
		if (!Reset_n) Q <= 0;
		else Q <= (Q == k-1) ? 0 : Q + 1;
	end
	
endmodule