`timescale 1ns / 1ns

module testbench();
    reg Rst_tb;
    reg Clk_tb;
    reg [7:0] A_tb;

    wire carry_tb;
    wire overflow_tb;
    wire [7:0] sum_tb;

    initial begin: CLOCK_GENERATOR
        Clk_tb = 0;
        forever #30 Clk_tb = ~Clk_tb;  // 60 ns period clock
    end

    initial begin
        Rst_tb = 1;
        A_tb   = 8'd0;

        #100;
        Rst_tb = 0; // Reset
		  #20;
		  Rst_tb = 1; // Release Reset

        // Test adding values
        A_tb = 8'd10;
        #200;  // wait a few cycles

        A_tb = 8'd20;
        #200;

        A_tb = 8'd100;
        #200;

        A_tb = 8'd50;
        #200;

        A_tb = 8'd127; // test signed overflow
        #200;

        A_tb = 8'd1;
        #200;

        // Test negative number (2's complement)
        A_tb = 8'd200; // 200 = -56 in 2's complement
        #200;

        A_tb = 8'd100;
        #200;

        $stop;
    end
	 
	 part1 p1 (
        .KEY0(Rst_tb),
        .KEY1(Clk_tb),
        .SW(A_tb),
        .LEDR({carry_tb, overflow_tb, sum_tb})
    );
	 
endmodule