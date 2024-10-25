module multi #(
    parameter    a_width = 24 ,
                 b_width = 16 ,
                 out_width = a_width + b_width 
) 

    (
    input logic signed [a_width-1:0] a,
    input logic signed [b_width-1:0] b,
    output logic signed [out_width-1:0] out
); 

assign out = a * b; 

endmodule: multi