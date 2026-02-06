module part3 (
	input 	    CLOCK_50, // 50 MHz
	output [0:6] HEX0
);

	reg [25:0] large_counter;
	reg [3:0]  small_counter;

	always @(posedge CLOCK_50) begin
		if(large_counter == 49_999_999) begin
			large_counter <= 0;
			if(small_counter == 9) small_counter <= 0;
			else small_counter <= small_counter + 1;
		end
		else large_counter <= large_counter + 1;
	end

	hex_decoder dec(
		.num(small_counter),
		.seg(HEX0)
	);
	
endmodule