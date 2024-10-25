module codec (
   input  logic       clk     , 
   input  logic       rst     ,
   input  logic [3:0] is_press,
   input  logic [9:0] sw      ,
   output logic       sclk    ,
   inout  wire        sdin    ,
   output logic       bclk    ,
   output logic       xck     ,
   output logic       daclrc  ,
   output logic       dac_data,
	output logic       clk_12M
);
   integer      count_bitpr;
   logic [23:0] adc_data;
   logic [ 9:0] read_addr;
   logic [ 9:0] rom_addr;
   logic [23:0] rom_out;
   logic        is_busy_wm, is_done, is_send_wm;
   logic [15:0] i2c_data_wm;
   logic [23:0] data_fir;


   pll_clock clock_12 (
      .refclk   (clk),
      .rst_n    (1'b1),
      .outclk_0 (clk_12M)
   );

   rom_sine rom (
      .clock   (clk_12M) ,
      .address (rom_addr),
      .q       (rom_out)
   );

   FIR_pipeline2 filter (
      .clk      (clk_12M),
      .reset_n  (1'b1)   ,
      .data_in  (rom_out),
      .data_out (data_fir)
   );

   parallel_serial convert (
      .clk_12M       (clk_12M) ,
      .bclk          (bclk)    ,
      .daclrc        (daclrc)  ,
      .data_par      (adc_data),
      .data_serial   (dac_data)
   );

   i2c i2c_configure (
      .clk      (clk)        ,
      .is_busy  (is_busy_wm) ,
      .is_send  (is_send_wm) ,
      .i2c_addr (8'b00110100),
      .i2c_data (i2c_data_wm),
      .is_done  (is_done)    ,
      .sclk     (sclk)       ,
      .sdin     (sdin)
   );
   
   assign rom_addr = read_addr;
   // put data from rom to process
   always_ff @(posedge clk_12M) begin 
      if (rst) begin 
         read_addr   <= 0;
         count_bitpr <= 0;
         adc_data    <= 24'h0;
      end else begin
         adc_data <= data_fir; // put data through filters
         if (daclrc) begin 
            if (count_bitpr < 5) begin // 8ksps
               count_bitpr <= count_bitpr + 1;
            end else begin 
               count_bitpr <= 0;
               if (read_addr < 1001) read_addr <= read_addr + 1;
               else read_addr <= 0;
            end
         end
      end
   end

   // config wm8731
   always_ff @(posedge clk) begin
      if (is_press == 4'b1111) begin
            is_send_wm <= 0;
        end
      if (!is_busy_wm) begin
         if (~is_press[0]) begin // Digital Interface: DSP, 24 bit, slave mode
            i2c_data_wm[15:9] <= 7'b0000111;
            i2c_data_wm[ 8:0] <= 9'b00001_1011;    
            is_send_wm        <= 1'b1;
            end else if (~is_press[0] && sw[0]) begin // HEADPHONE VOLUME
               i2c_data_wm[15:9] <= 7'b0000010;
               i2c_data_wm[ 8:0] <= 9'b101111001;
               is_send_wm        <= 1;
            end else if (~is_press[1] && ~sw[0]) begin // ADC off, DAC on, Linout ON, Power ON
               i2c_data_wm[15:9] <= 7'b0000110;
               i2c_data_wm[ 8:0] <= 9'b000000111;
               is_send_wm        <= 1;
            end else if (~is_press[1] && sw[0]) begin // USB mode
               i2c_data_wm[15:9] <= 7'b0001000;
               i2c_data_wm[ 8:0] <= 9'b000000001;
               is_send_wm        <= 1;
            end else if (~is_press[2] && ~sw[0]) begin // active interface
               i2c_data_wm[15:9] <= 7'b0001001;
               i2c_data_wm[ 8:0] <= 9'b111111111;
               is_send_wm        <= 1;
            end else if (~is_press[2] && sw[0]) begin // Enable DAC to LINOUT
               i2c_data_wm[15:9] <= 7'b0000100;
               i2c_data_wm[ 8:0] <= 9'b000010010;
               is_send_wm        <= 1;
            end else if (~is_press[3] && ~sw[0]) begin // remove mute DAC
               i2c_data_wm[15:9] <= 7'b0000101;
               i2c_data_wm[ 8:0] <= 9'b000000000;
               is_send_wm        <= 1;
            end else if (~is_press[3] && sw[0]) begin // reset
               i2c_data_wm[15:9] <= 7'b0001111;
               i2c_data_wm [8:0] <= 9'b000000000;
               is_send_wm        <= 1;
            end
        end
    end

endmodule : codec