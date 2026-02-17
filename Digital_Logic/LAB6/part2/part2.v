module part2 #(
	parameter n = 8
) (
	input 		       Clock,
	input 				 Reset, // active-low asynchronous reset
	input      [n-1:0] A,
	input					 add_sub, // If high substract, if low add
	output reg         carry,
	output reg         overflow,
	output reg [n-1:0] S
);

	wire [n:0]   sum;
	wire [n-1:0] A_mod;
	assign A_mod = add_sub ? ~A : A;
	assign sum   = S + A_mod + add_sub;
	
	always @(posedge Clock or negedge Reset) begin
		if(!Reset) begin
			carry <= 0;
			overflow <= 0;
			S <= 0;
		end else begin
			{carry, S} <= sum;
			overflow <= (~(A_mod[n-1] ^ S[n-1])) & (sum[n-1] ^ S[n-1]);
		end
	end

endmodule