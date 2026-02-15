module accumulator #(
	parameter n
) (
	input 		       Clock,
	input 				 Reset, // active-low asynchronous reset
	input      [n-1:0] A,
	output reg         carry,
	output reg         overflow,
	output reg [n-1:0] S
);

	wire [n:0] sum;
	assign sum = A + S;
	
	always @(posedge Clock or negedge Reset) begin
		if(!Reset) begin
			carry <= 0;
			overflow <= 0;
			S <= 0;
		end else begin
			{carry, S} <= sum;
			overflow <= (~(A[n-1] ^ S[n-1])) & (sum[n-1] ^ S[n-1]);
		end
	end

endmodule