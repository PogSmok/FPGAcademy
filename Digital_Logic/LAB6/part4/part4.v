module part4 (
	input  [9:0] SW,   // SW[9]=ENABLE A, SW[8]=ENABLE B, SW[7:0]=DATA
	input   		 KEY0, // Active low synchronous reset
	input			 KEY1, // Clock
	output [0:6] HEX0,
	output [0:6] HEX1,
	output [0:6] HEX2,
	output [0:6] HEX3,
	
	output reg [7:0] LEDR
);

	wire [15:0] p; // product
	wire [7:0]  a;
	wire [7:0]  b;
	register_multiplier u_mul_reg (
		.EA(SW[9]), .EB(SW[8]), .Data(SW[7:0]),
		.Clk(KEY1), .Rst(KEY0),
		.Q(p), .A(a), .B(b)
	);
	
	hex_decoder u_dec0 (.num(p[3:0]), .seg(HEX0));
	hex_decoder u_dec1 (.num(p[7:4]), .seg(HEX1));
	hex_decoder u_dec2 (.num(p[11:8]), .seg(HEX2));
	hex_decoder u_dec3 (.num(p[15:12]), .seg(HEX3));
	
	always @(*) begin
		if(SW[9]) LEDR <= a;
		else if(SW[8]) LEDR <= b;
		else LEDR <= 8'b0;
	end

endmodule