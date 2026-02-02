`timescale 1ns / 1ns

module testbench ();
	reg  Clk_tb;
	reg  D_tb;
	wire Q_tb;
	
	initial
		begin: CLOCK_GENERATOR
			Clk_tb = 0;
			forever
				begin
					#5 Clk_tb = ~Clk_tb;
				end
		end
		
	initial
		begin
			D_tb = 1;
			#10 D_tb = 0;
			#7  D_tb = 1;
			#10 D_tb = 0;
			#5  $stop;
		end
		
	part3 p3(.SW0(D_tb), .SW1(Clk_tb), .LEDR0(Q_tb));	
		
endmodule