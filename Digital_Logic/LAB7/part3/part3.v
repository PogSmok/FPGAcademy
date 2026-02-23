module part3 (
	input        SW0,  // active-low asynchronous reset
	input        SW1,  // w signal
	input        KEY0, // clock 
	output [9:0] LEDR  // LEDR[9]=z signal, LEDR[8:0]=state
);
	
	reg [3:0] w_high, w_low;

	always @(posedge KEY0 or negedge SW0) begin
		if(!SW0) begin
			w_high <= 4'b0;
			w_low  <= 4'b0;
		end else begin
			w_high <= {w_high[2:0], SW1};
			w_low  <= {w_low[2:0], ~SW1};
		end
	end
	
	assign LEDR[3:0] = w_high;
	assign LEDR[7:4] = w_low;
	assign LEDR[8]   = 0; // unused
	assign LEDR[9]   = (w_high == 4'b1111 | w_low == 4'b1111);

endmodule