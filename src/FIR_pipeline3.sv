`timescale 1ns/1ns
module FIR_pipeline3 #(
    parameter WIDTH_data =  24,
    parameter WIDTH_coeff = 16,
    parameter TAP =         111,
    parameter WIDTH_reg =   WIDTH_data + WIDTH_coeff 
) 
(
    input logic                            clk,
    input logic                            reset_n,
    input logic signed  [WIDTH_data-1:0]   data_in,
    output logic signed [WIDTH_data-1:0]   data_out
); 

// Araays --

logic signed [WIDTH_reg-1:0] mul        [TAP-1:0]; // array for result multiply 
logic signed [WIDTH_reg-1:0] delay      [TAP-1:0]; // array for pipeline delay stage 1
logic signed [WIDTH_reg-1:0] reg_pipe1  [TAP-1:0]; // array for pipeline delay stage 1
logic signed [WIDTH_reg-1:0] reg_pipe2  [TAP-1:0]; // array for pipeline stage 2
logic signed [WIDTH_reg-1:0] add_result [TAP-1:0]; // array for result addition
logic signed [WIDTH_reg-1:0] reg_in     [TAP-1:0]; // store to array data in
logic signed [WIDTH_coeff-1:0] h        [TAP-1:0]; // coeffs lowpass filter 1KHZ

assign delay[0] = 0; // first tap doesnt had delay

// store coeffs value
initial begin 
    $readmemh ("../../FIR/mem/audio_111_hex.txt", h);
end 

//store data in 
genvar q;
 generate
    for (q = 0; q < TAP; q = q + 1) begin: store_data_in 
       assign reg_in[q] = data_in;
    end
 endgenerate

// Data in pipeline 1
genvar i; 
 generate
     for (i = 0; i < TAP; i = i + 1) begin: pipeline1 
        my_DFF dff1 (
            .clk(clk),
            .rst_n(reset_n),
            .d_in(reg_in[i]),
            .q_out(reg_pipe1[i])
        );
     end
 endgenerate

 // multi result 
 genvar k; 
 generate
     for (k = 0; k < TAP; k = k +1) begin: multi
        multi mult (
            .a(reg_pipe1[k]),
            .b(h[k]),
            .out(mul[k])
        );
	end
 endgenerate

 // Data in pipeline 2

genvar e; 
 generate
     for (e = 0; e < TAP; e = e + 1) begin: pipeline2 
        my_DFF_40 dff2 (
            .clk(clk),
            .rst_n(reset_n),
            .d_in(mul[e]),
            .q_out(reg_pipe2[e])
        );
     end
 endgenerate

  // delay 

   genvar p; 
 generate
     for (p = 0; p < TAP-1; p = p + 1) begin:delay_ff 
        my_DFF_40 delayf (
            .clk(clk),
            .rst_n(reset_n),
            .d_in(add_result[p]),
            .q_out(delay[p+1])
        );
     end
 endgenerate

 // add result 
 genvar j; 
  generate
    for (j = 0; j < TAP; j = j + 1) begin: result
        assign add_result[j] = reg_pipe2[j] + delay[j];
	end
  endgenerate

// data out 
  assign data_out = add_result[TAP-1][WIDTH_reg-1:WIDTH_reg-24]; 
  
endmodule : FIR_pipeline3 