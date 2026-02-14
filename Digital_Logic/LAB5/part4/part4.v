module part4 (
	input      [2:0] SW,
	input 	        KEY0,     // Reset (active low)
	input 	   	  KEY1, 	   // Select (active low)
	input 	   	  CLOCK_50, // 50 MHz
	output reg       LEDR0
);

	// 1Hz generator (0.5s pulse)
	wire signal_1hz;
	counter #(.n(26), .k(25_000_000)) u_1hz (
		.Clock(CLOCK_50),
		.Reset_n(1),
		.Enable(1),
		.Rollover(signal_1hz)	
	);
	
	wire [3:0] morse;
	wire [2:0] morse_len;
	decode_morse u_morse (.code(SW), .morse(morse), .length(morse_len));
	
	reg [3:0] loaded_morse = 0;
	reg [2:0] loaded_len = 0;
	always @(negedge KEY1 or negedge KEY0) begin
		if(!KEY0) begin
			loaded_morse <= 0;
			loaded_len <= 0;
		end else begin
			loaded_morse <= morse;
			loaded_len <= morse_len;
		end
	end
	
	wire       morse_change = KEY0 & KEY1;
	reg  [1:0] light_left = 0;
	reg  [2:0] chars_left = 0;
	always @(posedge signal_1hz or negedge morse_change) begin
		if(!morse_change) begin
			LEDR0 <= 0;
			chars_left <= loaded_len;
		end else begin
			if (light_left > 0) begin
				LEDR0 <= 1;
				light_left <= light_left - 1;
			end else if(chars_left == 0) LEDR0 <= 0;
			else begin
				LEDR0 <= 0;
				light_left <= loaded_morse[chars_left - 1] ? 3 : 1;
				chars_left <= chars_left - 1;
			end
		end
	end

endmodule