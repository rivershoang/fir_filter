module parallel_serial (
   input  logic        clk_12M ,
   input  logic [23:0] data_par, 
   output logic        bclk    ,
   output logic        daclrc  , 
   output logic        data_serial
); 
   logic        is_sample = 0;
   logic [ 5:0] count_bit_out = 0;
   logic [23:0] data_par_temp = 24'h0;
   integer      count_clock; 
   logic        en_active = 0;

   assign bclk = clk_12M; // bit clock
   // Data send pcm mode audio interface 
   always_ff @(posedge clk_12M) begin 
      daclrc <= en_active; // high in 1 clock of clk 12M
      
      if (count_clock < 250) begin // 48kHz for active high daclr clk
         count_clock <= count_clock + 1;
         en_active   <= 0;
      end else begin 
         count_clock   <= 0;
         en_active     <= 1;
         data_par_temp <= data_par; // get a sample
      end
      // send a new sample
      if (en_active) begin 
         is_sample     <= 1; // flag for a new sample
         count_bit_out <= 23; // count 24 bit out as serial data
      end 
      if (is_sample) begin 
         if (count_bit_out > 0) begin 
            data_serial   <= data_par_temp[count_bit_out]; // send MSB first 
            count_bit_out <= count_bit_out - 1;
         end else begin 
            data_serial <= data_par_temp[count_bit_out]; // finaly send LSB
            is_sample   <= 0; // wait for a new sample
         end
      end
   end

endmodule : parallel_serial