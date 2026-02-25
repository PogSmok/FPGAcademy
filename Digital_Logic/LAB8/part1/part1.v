module part1  (
	input  [4:0] address,
	input        clock,
	input  [3:0] data,
	input 		 wren,	
	output [3:0] q
);

	ram32x4 u_ram(
    .address(address),
    .clock(clock),
    .data(data),
    .wren(wren),
    .q(q)
	);

endmodule