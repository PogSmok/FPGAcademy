module t_flip_flop (
	input      Enable,
	input      Clock,
	input      Clear, // Active low
	output reg Q
);

always @(posedge Clock) begin
	if(!Clear) Q <= 0;
	else if(Enable) Q <= ~Q;
end

endmodule