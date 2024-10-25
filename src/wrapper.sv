module wrapper (
   // WM8731 pins
   output logic AUD_BCLK     ,
   output logic AUD_XCK      ,
   output logic AUD_ADCLRCK  ,
   input  logic AUD_ADCDAT   ,
   output logic AUD_DACLRCK  ,
   output logic AUD_DACDAT   ,
   // FPGA pins
   input  logic CLOCK_50     ,
   input  logic [3:0] KEY    ,
   input  logic [9:0] SW     ,
   output logic FPGA_I2C_SCLK,
   inout  wire  FPGA_I2C_SDAT
);

   codec kit (
      .clk      (CLOCK_50)     ,
      .rst      (SW[9])        , 
      .is_press (KEY)          ,
      .sclk     (FPGA_I2C_SCLK),
      .sdin     (FPGA_I2C_SDAT),
      .bclk     (AUD_BCLK)     ,
      .clk_12M  (AUD_XCK)      ,
      .daclrc   (AUD_DACLRCK)  ,
      .dac_data (AUD_DACDAT)
   );

endmodule : wrapper 