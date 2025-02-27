module top (
   input  logic         clk            ,
   input  logic         reset_n        ,
   input  logic [3:0]   is_key_config  ,
   input  logic [9:0]   sw             ,

   output logic         bclk           ,
   output logic         serial_data    ,
   output logic         xck            ,
   output logic         daclrck        ,
   output               sclk           ,
   output               sdin           ,
   output logic [9:0]   led_red
);

   logic clk_12M, clk_400K, clk_sample ;
   logic [23:0]   gain_coeff        , 
                  data_send_filter  ,
                  data_filterd      ,
                  data_filter_amp   ,
                  data_osc          ;
   logic [15:0]   addr_RAM;
   logic          done_config;

	assign xck = clk_12M;
	
   clk_400K clock_gen_400K (
      .clk_in  (clk)    ,
      .reset_n (reset_n),
      .clk_out (clk_400K)
   );

   clk_12M clock_gen_12M (
      .clk_in  (clk)    ,
      .reset_n (reset_n),
      .clk_out (clk_12M)
   );

   single_port_RAM data_in_RAM (
      .clk     (clk_sample),
      .cs      (1'b1)      ,
      .we      (1'b0)      ,
      .addr    (addr_RAM)  ,
      .w_data  (24'd0)     ,
      .r_data  (data_send_filter)
   );

   count_addr_RAM count_addr (
      .clk     (clk_sample),
      .reset_n (reset_n)   ,
      .addr    (addr_RAM)
   );

   FIR_pipeline2 fir (
      .clk        (clk_sample)      ,
      .reset_n    (reset_n)         ,
      .data_in    (data_send_filter),
      .data_out   (data_filterd)
   );

   gain gain_amp (
      .data_in    (data_filterd) ,
      .gain_coeff (gain_coeff)   ,
      .data_out   (data_filter_amp)
   );

   assign data_osc = (sw[0]) ? data_filter_amp : data_send_filter;

   // gain x1024
   always_ff @(posedge is_key_config[2] or negedge reset_n) begin 
      if (~reset_n)  gain_coeff = 24'h000400;
      else           gain_coeff = 24'h000400;
   end 
   
   // codec
   audio_codec codec (
      .clk_i2c    (clk_400K)        ,
      .reset_n    (reset_n)         ,
      .is_config  (is_key_config[1]),
      .sclk       (sclk)            ,
      .sdin       (sdin)            ,
      .done       (done_config)
   );

   paralell_serial p2s (
      .clk_12M       (clk_12M)      ,
      .start         (done_config)  ,
      .data_paralell (data_osc)     ,
      .bclk          (bclk)         ,
      .lrclk         (daclrck)      ,
      .clk_fsample   (clk_sample)   ,
      .data_serial   (serial_data)
   );

endmodule 



   