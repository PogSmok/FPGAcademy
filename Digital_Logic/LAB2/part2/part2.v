module part2 (
	input  [3:0] SW,	 // Value displayed in decimal on HEX1 and HEX0
	output [0:6] HEX0, // 7-segment display for unit place
   output [0:6] HEX1  // 7-segment display for tens place
);
	
	wire is_gt9;
	comp_gt9 ucomp_gt9(.val(SW), .gt9(is_gt9));
	
	wire [3:0] ones;
	get_ones uget_ones(.num(SW), .ones(ones));
	
	// If SW > 9 HEX0 gets unit place
	// else HEX0 gets entire number
	wire [3:0] bcd0_in;
	mux_4bit_2to1 umux_4bit_2to1(.s(is_gt9), .x(SW), .y(ones), .m(bcd0_in));
	
	bcd ubcd0(.binary(bcd0_in), .seg(HEX0));
	bcd ubcd1(.binary(is_gt9), .seg(HEX1));

endmodule