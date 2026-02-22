module part2 (
	input        SW0,  // active-low asynchronous reset
	input        SW1,  // w signal
	input        KEY0, // clock 
	output [9:0] LEDR  // LEDR[9]=z signal, LEDR[8:0]=state
);

	localparam [3:0] 
		A = 4'b0000,
		B = 4'b0001,
		C = 4'b0010,
		D = 4'b0011,
		E = 4'b0100,
		F = 4'b0101,
		G = 4'b0110,
		H = 4'b0111,
		I = 4'b1000;
		
	reg [3:0] y_Q, Y_D; // y_Q represents current state, Y_D represents next state
	
	always @(SW1, y_Q) begin
		case(y_Q)
        A: Y_D = (!SW1) ? B : F;	
        B: Y_D = (!SW1) ? C : F;
        C: Y_D = (!SW1) ? D : F;
        D: Y_D = (!SW1) ? E : F;
        E: Y_D = (!SW1) ? E : F;
        F: Y_D = (!SW1) ? B : G;
        G: Y_D = (!SW1) ? B : H;
        H: Y_D = (!SW1) ? B : I;
        I: Y_D = (!SW1) ? B : I;
        default: Y_D = A;
		endcase
	end
	
	always @(posedge KEY0 or negedge SW0) begin
		if(!SW0) y_Q <= A;
		else     y_Q <= Y_D;
	end
	
	assign LEDR[8:0] = y_Q;
	assign LEDR[9]   = (y_Q == E || y_Q == I);

endmodule