module parallel_serial_tb;

   // Parameters
   localparam CLK_PERIOD = 83; // 12MHz clock period in ns (1 / 12MHz = 83.33ns)

   // Signals
   logic clk_12M;
   logic [23:0] data_par;
   logic bclk;
   logic dalrc;
   logic data_serial;

   // Instantiate the module under test
   parallel_serial dut (
       .clk_12M(clk_12M),
       .data_par(data_par),
       .bclk(bclk),
       .dalrc(dalrc),
       .data_serial(data_serial)
   );

   // Generate the clock signal
   initial begin
       clk_12M = 0;
       forever #(CLK_PERIOD / 2) clk_12M = ~clk_12M; // Toggle clock
   end

   // Test procedure
   initial begin
       // Test with first data
       data_par = 24'hA5A5A5; // Example data input 1
       
       // Wait for some time to stabilize
       #(100 * CLK_PERIOD);

       // Start sending first data
       #(250 * CLK_PERIOD); // Wait to ensure we catch all output changes

       // Test with second data after a delay
       data_par = 24'ha12345; // Example data input 2
       
       #(250 * CLK_PERIOD); // Wait to ensure we catch all output changes

   end

   // Finish the simulation after a certain period
   initial begin
       #(2000 * CLK_PERIOD);
       $finish;
   end

endmodule : parallel_serial_tb
