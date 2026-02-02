// All 7-segment displays display hex values of bits
module part5 (
	input  [7:0] SW,
	input 		 KEY0, // Active low asynchronous reset
	input 		 KEY1, // Clock signal
	output [0:6] HEX0, // B[0:3]
	output [0:6] HEX1, // B[4:7]
	output [0:6] HEX2, // A[0:3]
	output [0:6] HEX3, // A[4:7]
	output [0:6] HEX4, // S=A+B, S[0:3]
	output [0:6] HEX5, // S=A+B, S[4:7]
	output 		 LEDR0 // Carry out
);

	reg [7:0] A; 
	
	always @(posedge KEY1 or negedge KEY0) begin
		if(!KEY0) A <= 8'h00;
		else A <= SW;
	end

	wire [7:0] S;
	assign {LEDR0, S} = A + SW;
	
	// Display A
	hex_decoder A_low  (.num(A[3:0]), .seg(HEX2));
	hex_decoder A_high (.num(A[7:4]), .seg(HEX3));
	
	// Display B
	hex_decoder B_low  (.num(SW[3:0]), .seg(HEX0));
	hex_decoder B_high (.num(SW[7:4]), .seg(HEX1));
	
	// Display S=A+B
	hex_decoder S_low  (.num(S[3:0]), .seg(HEX4));
	hex_decoder S_high (.num(S[7:4]), .seg(HEX5));

endmodule