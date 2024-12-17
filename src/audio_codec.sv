module audio_codec (
   input  logic clk_i2c    ,
   input  logic reset_n    ,
   input  logic is_config  ,
   
   output       sclk       ,
   output       sdin       ,
   output logic done
);

   logic       busy     ,
               ack_i2c  ,
               wr_send  ;
   logic [6:0] addr;
   logic [7:0] data_st_send,
               data_nd_send;

   config_codec configcodec (
      .clk           (clk_i2c)      ,
      .reset_n       (reset_n)      ,
      .is_config     (is_config)    ,
      .busy          (busy)         ,
      .done_config   (done)         ,
      .ack_i2c       (ack_i2c)      ,
      .addr          (addr)         ,
      .wr_rd         (wr_send)      ,
      .addr_reg      (data_st_send) ,
      .data_config   (data_nd_send)
   );

   i2c_protocol i2c (
      .clk     (clk_i2c)      ,
      .reset_n (reset_n)      ,
      .start   (ack_i2c)      ,
      .addr    (addr)         ,
      .wr_rd   (wr_send)      ,
      .data_st (data_st_send) ,
      .data_nd (data_nd_send) ,
      .busy    (busy)         ,
      .done    ()             ,
      .sclk    (sclk)         ,
      .sdin    (sdin)
   );

endmodule 