`timescale 1ns / 1ns

module testbench();
	
	reg  [3:0] A;
	reg  [3:0] B;
	wire [7:0] P;

	initial begin
      $monitor("A = %0d (%b), B = %0d (%b) --> P = %0d (%b)", A, A, B, B, P, P);
		A = 1;    B = 0;    #10;
		A = 7;    B = 5;    #10;
		A = 8;    B = 9;    #10;
		A = 4'hf; B = 4'hf; #10;
		$stop;
	end

	array_multiplier_4bit u_mult (.A(A), .B(B), .P(P));
 
endmodule