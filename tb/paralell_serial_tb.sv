module paralell_serial_tb;

    // Testbench signals
    logic clk_12M;
    logic start;
    logic [23:0] data_paralell;

    logic data_serial;
    logic bclk;
    logic lrclk;
    logic clk_fsample;

    // Instantiate the DUT (Device Under Test)
    paralell_serial dut (
        .clk_12M        (clk_12M)       ,
        .start          (start)         ,
        .data_paralell  (data_paralell) ,
        .data_serial    (data_serial)   ,
        .bclk           (bclk)          ,
        .lrclk          (lrclk)         ,
        .clk_fsample    (clk_fsample)
    );

    // Clock generation (12 MHz)
    always #41.67 clk_12M = ~clk_12M; // Period = 83.33 ns (12 MHz)

    // Testbench logic
    initial begin
        // Initialize signals
        clk_12M = 0;
        start = 0;
        data_paralell = 24'h0;

        // Display header
        $display("Time\tclk_12M\tstart\tdata_paralell\tdata_serial\tbclk\tlrclk\tclk_fsample");

        // Wait for a few clock cycles
        repeat (5) @(posedge clk_12M);

        // Provide first test input
        data_paralell = 24'haaafaa; // Test data
        start = 1; // Trigger start
        @(posedge clk_12M);
        start = 0; // Deassert start

        // Wait and monitor the outputs
        repeat (300) @(posedge clk_12M);

        // Provide second test input
        data_paralell = 24'h123456; // Test data
        start = 1; // Trigger start
        @(posedge clk_12M);
        start = 0; // Deassert start

        // Wait and monitor the outputs
        repeat (300) @(posedge clk_12M);

        // End simulation
        $finish;
    end

    // Monitor for debug purposes
    always @(posedge clk_12M) begin
        $display("%0t\t%b\t%b\t%h\t%b\t%b\t%b\t%b", 
            $time, clk_12M, start, data_paralell, data_serial, bclk, lrclk, clk_fsample);
    end

endmodule
