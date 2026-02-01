module part5 (
	input  [8:0] SW,    // SW[8]=carry in, SW[7:4]=X, SW[3:0]=Y
	output [0:6] HEX5,  // BCD display for X
	output [0:6] HEX3,  // BCD display for Y
	output [0:6] HEX1,  // Tens place of X+Y
	output [0:6] HEX0,  // Ones place of X+Y
	output       LEDR9  // Error indication (X or Y > 9)
);

	assign LEDR9 = SW[7:4] > 9 || SW[3:0] > 9; // Indicate addends are out of operational range
	
	wire [4:0] sum = SW[7:4] + SW[3:0] + SW[8];
	reg  [4:0] correction;
	reg  [3:0] tens;
	
	always @ (*) begin
		if (sum > 5'd9) begin
			correction = 5'd10;
			tens       = 4'd1;
		end
		else begin
			correction = 5'd0;
			tens       = 4'd0;
		end
	end
	
	bcd u5_bcd(
		.binary(SW[7:4]),
		.seg(HEX5)
	);
	
	bcd u3_bcd(
		.binary(SW[3:0]),
		.seg(HEX3)
	);
	
	bcd u1_bcd(
		.binary(tens),
		.seg(HEX1)
	);
	
	bcd u0_bcd(
		.binary(sum - correction), // MSB is truncated, BCD uses 4-bit
		.seg(HEX0)
	);
	
endmodule