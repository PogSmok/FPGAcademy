module part3 (
	input  [7:0] SW, // SW[7:4]=A, SW[3:0]=B
	output [0:6] HEX0, // A 
	output [0:6] HEX2, // B
	output [0:6] HEX4, // Low byte of product
	output [0:6] HEX5  // High byte of product
);
	
	wire [7:0] product;
	array_multiplier_4bit u_mult (.A(SW[7:4]), .B(SW[3:0]), .P(product));
	
	hex_decoder u_dec0 (.num(SW[3:0]), .seg(HEX0));
	hex_decoder u_dec2 (.num(SW[7:4]), .seg(HEX2));
	hex_decoder u_dec4 (.num(product[3:0]), .seg(HEX4));
	hex_decoder u_dec5 (.num(product[7:4]), .seg(HEX5));
	
endmodule