module part4 (
	input       KEY0, // display character
	input       KEY1, // asynchronous reset
	input [2:0] SW,   // character select
	input       CLOCK_50,
	output reg  LEDR0
);

	 wire [3:0] morse;
	 wire [2:0] len;
	 decode_morse u_dec(
		.code(SW[2:0]),
		.morse(morse),
		.length(len)
	 );
		 
	reg [24:0] large_counter; // used to detect when 0.5s passes
	reg [2:0]  time_counter;  // number of 0.5s that passed
	reg [2:0]  loaded_len;    // remaining lenght
	reg [3:0]  loaded_morse;  // current morse code
	 
	always @(posedge CLOCK_50, negedge KEY1) begin
		if(!KEY1) begin
			large_counter <= 0;
			time_counter <= 0;
			LEDR0 <= 0;
		end else if(y_Q == IDLE) begin
			LEDR0 <= 0;
		end else if(y_Q == LOAD_MORSE) begin
			loaded_len <= len;
			loaded_morse <= morse;
			time_counter <= 0;
			LEDR0 <= 0;
		end else if(y_Q == LOAD_NEXT_CHAR) begin
			time_counter <= 0;
			LEDR0 <= 0;
		end else if(y_Q == DISPLAY_3HALFS || y_Q == DISPLAY_1HALF) begin
			LEDR0 <= 1;
			if(large_counter == 25_000_000 - 1) begin
				large_counter <= 0;
				time_counter <= time_counter + 1;
				if(time_counter == 0) loaded_len <= loaded_len - 1;
			end else large_counter <= large_counter + 1;
		end else if(y_Q == OFF_1HALF) begin
			LEDR0 <= 0;
			if(large_counter == 25_000_000 - 1) begin
				large_counter <= 0;
				time_counter <= 0;
			end else large_counter <= large_counter + 1;
		end
	end
	 
	localparam [2:0]
		IDLE           = 3'b000,
		LOAD_MORSE     = 3'b001,
		LOAD_NEXT_CHAR = 3'b010,
		DISPLAY_3HALFS = 3'b011,
		DISPLAY_1HALF  = 3'b100,
		OFF_1HALF      = 3'b101;

	reg [2:0] y_Q, Y_D;
	
	always @(*) begin
		case(y_Q)
			IDLE: Y_D = KEY0 ? IDLE : LOAD_MORSE;
			LOAD_MORSE: Y_D = LOAD_NEXT_CHAR;
			LOAD_NEXT_CHAR: 
				if(loaded_len == 0) Y_D = IDLE;
				else Y_D = loaded_morse[loaded_len-1] ? DISPLAY_3HALFS : DISPLAY_1HALF;
				
			DISPLAY_3HALFS: Y_D = time_counter == 3 ? OFF_1HALF : DISPLAY_3HALFS;
			DISPLAY_1HALF:  Y_D = time_counter == 1 ? OFF_1HALF : DISPLAY_1HALF;
			OFF_1HALF: 		 Y_D = time_counter == 0 ? LOAD_NEXT_CHAR : OFF_1HALF;
			default:        Y_D = IDLE;
		endcase
	end
	
	always @(posedge CLOCK_50, negedge KEY1) begin
		if(!KEY1) y_Q <= IDLE;
		else y_Q <= Y_D;
	end
	
endmodule