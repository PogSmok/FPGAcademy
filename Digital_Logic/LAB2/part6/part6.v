module part6 (
	input  [5:0] SW,
	output [0:6] HEX1, // Tens place
	output [0:6] HEX0  // Ones place
);
	reg [3:0] tens;
	reg [3:0] ones;
	
	// Alternatively tens=SW/10 and ones=SW%10, but such solution bypasses exercise’s intent
	always @(*) begin
		 if (SW >= 60) begin tens = 6; ones = SW - 60; end
		 else if (SW >= 50) begin tens = 5; ones = SW - 50; end
		 else if (SW >= 40) begin tens = 4; ones = SW - 40; end
		 else if (SW >= 30) begin tens = 3; ones = SW - 30; end
		 else if (SW >= 20) begin tens = 2; ones = SW - 20; end
		 else if (SW >= 10) begin tens = 1; ones = SW - 10; end
		 else begin tens = 0; ones = SW[3:0]; end
	end

	bcd u1_bcd(
		.binary(tens),
		.seg(HEX1)
	);
	
	bcd u0_bcd(
		.binary(ones),
		.seg(HEX0)
	);

endmodule