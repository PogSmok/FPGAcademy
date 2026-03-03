module regn #(
	parameter n = 16
) (
    input [n-1:0] R,
    input 			Resetn,
	 input			Rin,
	 input		   Clock,
    output reg [n-1:0] Q
);

	always @(posedge Clock)
		if (!Resetn) Q <= 0;
		else if (Rin) Q <= R;
		
endmodule