module part4 (
	input        CLOCK_50, // 50_MHz
	output [0:6] HEX0, // Right-most 7_segment display
	output [0:6] HEX1,
	output [0:6] HEX2,
	output [0:6] HEX3  // Left-most 7_segment display
);

	reg [25:0] large_counter; 
	reg [1:0]  small_counter;
	
	always @(posedge CLOCK_50) begin
		if(large_counter == 49_999_999) begin
			large_counter <= 0;
			small_counter <= small_counter + 1;
		end
		else large_counter <= large_counter + 1;
	end

	decoder_7seg u_dec0 (
		.code(small_counter+3),
		.segments(HEX0)
	);
	
	decoder_7seg u_dec1 (
		.code(small_counter+2),
		.segments(HEX1)
	);
	
	decoder_7seg u_dec2 (
		.code(small_counter+1),
		.segments(HEX2)
	);
	
	decoder_7seg u_dec3 (
		.code(small_counter),
		.segments(HEX3)
	);

endmodule