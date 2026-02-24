module decode_morse (
    input      [2:0] code,  // right-aligned
    output reg [3:0] morse, // 0 = dot, 1 = dash
    output reg [2:0] length
);

	always @(*) begin
		case (code)

			// A: .-
			3'b000: begin
				morse  = 4'bxx01;
				length = 2;
			end

			// B: -...
			3'b001: begin
				morse  = 4'b1000;
				length = 4;
			end

			// C: -.-.
			3'b010: begin
				morse  = 4'b1010;
				length = 4;
			end

			// D: -..
			3'b011: begin
				morse  = 4'bx100;
				length = 3;
			end

			// E: .
			3'b100: begin
				morse  = 4'bxxx0;
				length = 1;
			end

			// F: ..-.
			3'b101: begin
				morse  = 4'b0010;
				length = 4;
			end

			// G: --.
			3'b110: begin
				morse  = 4'bx110;
				length = 3;
			end

			// H: ....
			3'b111: begin
				morse  = 4'b0000;
				length = 4;
			end

			default: begin
				morse  = 4'bxxxx;
				length = 0;
			end

		endcase
	end

endmodule