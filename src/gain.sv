module gain (
   input  logic signed [23:0] data_in     ,
   input  logic signed [23:0] gain_coeff  ,
   
   output logic signed [23:0] data_out
);
   logic signed [47:0] mul_temp;

   assign mul_temp = data_in * gain_coeff;
   assign data_out = mul_temp[33:10];

endmodule 