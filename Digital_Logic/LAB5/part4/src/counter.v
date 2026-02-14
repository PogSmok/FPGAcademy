module counter #(
	parameter 		    n, // counter size 
	parameter  [n-1:0] k  // roll-over value
)(
	input              Clock,
	input              Reset_n, // active-low async reset
	input					 Enable,
	output reg         Rollover,
	output reg [n-1:0] Q
);

always @(posedge Clock or negedge Reset_n) begin
    if (!Reset_n) begin
        Q <= 0;
        Rollover <= 0;
    end else if (Enable) begin
        Q <= (Q == k-1) ? 0 : Q + 1;
        Rollover <= (Q == k-1);
    end
end

endmodule