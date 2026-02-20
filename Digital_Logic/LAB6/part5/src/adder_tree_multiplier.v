module adder_tree_multiplier (
	input  [7:0]  A,
	input  [7:0]  B,
	output [15:0] P
);

	wire [15:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;
	assign pp0 = B[0] ? ({8'b0, A} << 0) : 16'b0;
	assign pp1 = B[1] ? ({8'b0, A} << 1) : 16'b0;
	assign pp2 = B[2] ? ({8'b0, A} << 2) : 16'b0;
	assign pp3 = B[3] ? ({8'b0, A} << 3) : 16'b0;
	assign pp4 = B[4] ? ({8'b0, A} << 4) : 16'b0;
	assign pp5 = B[5] ? ({8'b0, A} << 5) : 16'b0;
	assign pp6 = B[6] ? ({8'b0, A} << 6) : 16'b0;
	assign pp7 = B[7] ? ({8'b0, A} << 7) : 16'b0;

	// Top layer
	wire [15:0] T0, T1, T2, T3;
	assign T0 = pp0 + pp1;
	assign T1 = pp2 + pp3;
	assign T2 = pp4 + pp5;
	assign T3 = pp6 + pp7;
	
	// Mid layer
	wire [15:0] M0, M1;
	assign M0 = T0 + T1;
	assign M1 = T2 + T3;
	
	// Last layer
	assign P = M0 + M1;
	
endmodule