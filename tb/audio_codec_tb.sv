`timescale 1ns/1ps

module audio_codec_tb;

    // Declare inputs as reg and outputs as wire
    reg clk_i2c;
    reg reset_n;
    reg is_config;
    wire sclk;
    wire sdin;
    wire done;

    // Instantiate the audio_codec module
    audio_codec uut (
        .clk_i2c    (clk_i2c)   ,
        .reset_n    (reset_n)   ,
        .is_config  (is_config) ,
        .sclk       (sclk)      ,
        .sdin       (sdin)      ,
        .done       (done)
    );

    // Clock generation (I2C clock, 100 kHz = 10 us period)
    initial begin
        clk_i2c = 0;
        forever #1250 clk_i2c = ~clk_i2c; // 1 clock cycle = 10 us
    end

    // Stimulus block

    // Stimulus block
    initial begin
        // Initialize inputs
        reset_n = 0;
        is_config = 0;

        // Apply reset
        #5000; // Wait for 5 us
        reset_n = 1;

        // Test case 1: Simulate key press to start configuration
        #10000; // Wait for 10 us
        is_config = 1; // Simulate key press
        #5000;  // Wait for 5 us
        is_config = 0; // Release key

        // Wait for some time to observe outputs
        #100000;

        // Test case 2: Reset the system while busy
        reset_n = 0; // Apply reset
        #5000;
        reset_n = 1; // Release reset

        // Wait for some time to observe behavior after reset
        #50000000;

        // End simulation
        $finish;
    end

endmodule
