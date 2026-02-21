`timescale 1ns / 1ns

module testbench();

    // Inputs
    reg SW0;   // active-low reset
    reg SW1;   // w signal
    reg KEY0;  // clock

    // Outputs
    wire [9:0] LEDR;

    initial begin
        KEY0 = 0;
        forever #5 KEY0 = ~KEY0;
    end

    initial begin
        $monitor("Time=%0t ns: SW0=%b, SW1=%b | LEDR[9]=%b, LEDR[8:0]=%b", 
                  $time, SW0, SW1, LEDR[9], LEDR[8:0]);

        // Initial reset
        SW0 = 0; SW1 = 0; #10;   // assert reset
        SW0 = 1;                 // release reset

        // Apply a few w signal transitions
        SW1 = 0; #20;
        SW1 = 1; #20;
		  SW1 = 0; #100;
        SW1 = 1; #50;
		  SW1 = 0; #10

        $stop;
    end

    part1 u_fsm (
        .SW0(SW0),
        .SW1(SW1),
        .KEY0(KEY0),
        .LEDR(LEDR)
    );

endmodule
