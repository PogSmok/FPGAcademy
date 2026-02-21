module part1 (
	input        SW0,  // active-low asynchronous reset
	input        SW1,  // w signal
	input        KEY0, // clock 
	output [9:0] LEDR  // LEDR[9]=z signal, LEDR[8:0]=state
);
	
	reg  y8, y7, y6, y5, y4, y3, y2, y1, y0; // current state
	wire d8, d7, d6, d5, d4, d3, d2, d1, d0; // next state
	
	assign d0 = 1;
	assign d1 = (~y0 | y5 | y6 | y7 | y8) & (~SW1);
	assign d2 = y1 & (~SW1);
	assign d3 = y2 & (~SW1);
	assign d4 = (y3 | y4) & (~SW1);
	assign d5 = (~y0 | y1 | y2 | y3 | y4) & SW1;
	assign d6 = y5 & SW1;
	assign d7 = y6 & SW1;
	assign d8 = (y7 | y8) & SW1;
	
	always @(posedge KEY0 or negedge SW0) begin
		if(!SW0) begin
			y0 <= 0;
			y1 <= 0;
			y2 <= 0;
			y3 <= 0;
			y4 <= 0;
			y5 <= 0;
			y6 <= 0;
			y7 <= 0;
			y8 <= 0;
		end else begin
			y0 <= d0;
			y1 <= d1;
			y2 <= d2;
			y3 <= d3;
			y4 <= d4;
			y5 <= d5;
			y6 <= d6;
			y7 <= d7;
			y8 <= d8;
		end
	end
	
	assign LEDR[9] = y4 | y8; // Z output
	assign LEDR[8:0] = {y8, y7, y6, y5, y4, y3, y2, y1, y0}; // flip-flop state
	
endmodule