module part4 (
	input        KEY0,
	input  		 CLOCK_50,
	input  [9:0] SW, // SW[9]=wren, SW[8:4]=write address, SW[3:0]=data
	output [0:6] HEX0,
	output [0:6] HEX2,
	output [0:6] HEX3,
	output [0:6] HEX4,
	output [0:6] HEX5
);

	reg [4:0] read_addr;
	reg [24:0] counter;
	
	always @(posedge CLOCK_50 or negedge KEY0) begin
		if(!KEY0) begin
			read_addr <= 0;
			counter   <= 0;
		end else begin
			if(counter == 25_000_000-1) begin
				read_addr <= read_addr+1;
				counter <= counter+1;
			end else counter <= counter + 1;
		end
	end
	
	wire [3:0] read_data;
	
	ram32x4 u_ram(
		.clock(CLOCK_50),
		.data(SW[3:0]),
		.rdaddress(read_addr),
		.wraddress(SW[8:4]),
		.wren(SW[9]),
		.q(read_data)
	);
	
	hex_decoder u_hex0 (
		.num(read_data),
		.seg(HEX0)
	);
	
	hex_decoder u_hex2 (
		.num(read_addr[3:0]),
		.seg(HEX2)
	);
	
	hex_decoder u_hex3 (
		.num({3'b0, read_addr[4]}),
		.seg(HEX3)
	);
	
	hex_decoder u_hex4 (
		.num(SW[7:4]),
		.seg(HEX4)
	);
	
	hex_decoder u_hex5 (
		.num({3'b0, SW[8]}),
		.seg(HEX5)
	);

endmodule