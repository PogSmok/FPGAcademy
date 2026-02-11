/* 
 * Decodes a 4-bit binary digit into a 7-segment display pattern.
 * Valid input range: 0–9 (BCD)
 */
module bcd (
	input  [3:0] binary, // BCD digit (0–9)	
	output [6:0] seg     // 7-segment display output (active-low)
);
		assign seg[6] = (~binary[3] & ~binary[2] & ~binary[1] & binary[0]) | (binary[2] & ~binary[1] & ~binary[0]);
		assign seg[5] = (binary[2] & ~binary[1] & binary[0]) | (binary[2] & binary[1] & ~binary[0]);
		assign seg[4] = ~binary[2] & binary[1] & ~binary[0];
		assign seg[3] = (~binary[3] & ~binary[2] & ~binary[1] & binary[0]) | (binary[2] & ~binary[1] & ~binary[0]) | (binary[2] & binary[1] & binary[0]);
		assign seg[2] = (binary[2] & ~binary[1]) | binary[0];
		assign seg[1] = (~binary[3] & ~binary[2] & binary[0]) | (~binary[2] & binary[1]) | (binary[1] & binary[0]);
		assign seg[0] = (~binary[3] & ~binary[2] & ~binary[1]) | (binary[2] & binary[1] & binary[0]);
	
endmodule