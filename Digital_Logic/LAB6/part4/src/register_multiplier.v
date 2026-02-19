module register_multiplier (
	input        EA,
	input        EB,
	input [7:0]  Data,
	input        Clk,
	input        Rst, // Active low synchronous reset
	
	output reg [7:0]  A = 8'b0,
	output reg [7:0]  B = 8'b0,
	output reg [15:0] Q = 16'b0
);

	wire [15:0] P;
	
	always @(posedge Clk) begin
		if(!Rst) begin
			A <= 0;
			B <= 0;
			Q <= 0;
		end else begin
			if(EA) A <= Data;
			if(EB) B <= Data;
			Q <= P;
		end
	end
	
	array_multiplier #(.N(8)) u_mult (.A(A), .B(B), .P(P));

endmodule