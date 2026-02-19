module array_multiplier #(
	parameter N = 8
) (
	input  [N-1:0]   A,
	input  [N-1:0]   B,
	output [2*N-1:0] P
);

	wire [N-1:0] sums [N-2:0];
	wire [N-2:0] carries;
	wire [N-1:0] rows [N-1:0];
	
	genvar i, j;
	generate
		for(i = 0; i < N; i = i + 1) begin: iter_rows
		
			for(j = 0; j < N; j = j + 1) begin: iter_cols
				assign rows[i][j] = A[j] & B[i];
			end
		
			if(i == 0) begin 
				assign P[0] = rows[0][0];
			end else if(i == 1) begin
				assign {carries[0], sums[0]} = {1'b0, rows[0][N-1:1]} + rows[i];
				assign P[1] = sums[0][0];
			end else begin
				assign {carries[i-1], sums[i-1]} = {carries[i-2], sums[i-2][N-1:1]} + rows[i];
				assign P[i] = sums[i-1][0];
			end			
		end
	endgenerate
	
	assign P[2*N-1:N-1] = sums[N-2];
	
endmodule