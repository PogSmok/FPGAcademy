module part1_8bit (
	input 		 KEY0, // Clock
	input 		 SW0,  // Clear (active low)
	input 		 SW1,  // Enable
	output [0:6] HEX0, // Low 4-bits
	output [0:6] HEX1  // High 4-bits
);

	wire [7:0] counter;
	
	genvar i;
	generate 
		for (i = 0; i < 8; i = i + 1) begin: TFFS
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
	
	hex_decoder h_low (
		.num(counter[3:0]),
		.seg(HEX0)
	);
	
	hex_decoder h_high (
		.num(counter[7:4]),
		.seg(HEX1)
	);
	
endmodule