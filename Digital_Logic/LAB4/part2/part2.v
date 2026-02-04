module part2 (
	input 		 KEY0, // Clock
	input 		 SW0,  // Clear (active low)
	input 		 SW1,  // Enable
	output [0:6] HEX0, // Low  4-bits (1st byte)
	output [0:6] HEX1, // High 4-bits (1st byte)
	output [0:6] HEX2, // Low  4-bits (2nd byte)
	output [0:6] HEX3  // High 4-bits (2nd byte)
);

	wire [15:0] counter;

	genvar i;
	generate 
		for(i = 0; i < 16; i = i + 1) begin: TFFS
			if(i == 0) begin
				t_flip_flop tff (
					.Clock(KEY0),
					.Clear(SW0),
					.Enable(SW1),
					.Q(counter[0])
				);
			end
			else begin
				t_flip_flop tff (
					.Clock(KEY0),
					.Clear(SW0),
					.Enable(SW1 & (&counter[i-1:0])),
					.Q(counter[i])
				);
			end
		end
	endgenerate


	hex_decoder h1_low (
		.num(counter[3:0]),
		.seg(HEX0)
	);
	
	hex_decoder h1_high (
		.num(counter[7:4]),
		.seg(HEX1)
	);
	
	
	hex_decoder h2_low (
		.num(counter[11:8]),
		.seg(HEX2)
	);
	
	hex_decoder h2_high (
		.num(counter[15:12]),
		.seg(HEX3)
	);

endmodule