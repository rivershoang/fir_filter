`timescale 1ns/1ns

module FIR #(
    parameter   WIDTH_data =  24,
                WIDTH_coeff = 16,
                WIDTH_reg =   WIDTH_data + WIDTH_coeff,
                TAP =         111
) 
    (
    input logic                           clk,
    input logic                           reset_n,
    input logic signed [WIDTH_data-1:0]   data_in,
    output logic signed [WIDTH_data-1:0]  data_out
); 

// Araays --- 31 taps

logic signed [WIDTH_data-1:0]   reg_in    [TAP-1:0]; // array for data_in delay 
logic signed [WIDTH_reg-1:0]    mul       [TAP-1:0]; // array for result multiply 
logic signed [WIDTH_reg-1:0]    add_out   [0:TAP-1]; // array for result addition
logic signed [WIDTH_coeff-1:0]  h         [TAP-1:0];


// store coeffs value
initial begin 
    $readmemh ("../../FIR/mem/audio_111_hex.txt", h);
end 

assign reg_in[0] = data_in; // no delay value

// Data in through delay 

genvar i; 
 generate

     for (i = 0; i < TAP - 1; i = i + 1) begin: delayfirst 
        my_DFF ff (
            .clk(clk),
            .rst_n(reset_n),
            .d_in(reg_in[i]),
            .q_out(reg_in[i+1])
        );
     end
 endgenerate

 // multi result 

 genvar k; 
 generate
     for (k = 0; k < TAP; k = k +1) begin: multi_coeff
        multi mult (
            .a(reg_in[k]),
            .b(h[k]),
            .out(mul[k])
        );
	end
 endgenerate

 // add result 

 genvar j; 
  generate
    for (j = 0; j < TAP; j = j + 1) begin: add_result 
        if (j<TAP-1) begin 
        assign add_out[j] = mul[j] + add_out[j+1];
		end
        else begin 
            assign add_out[j] = mul[j];
        end
    end
  endgenerate

  // output result

  assign data_out = add_out[0][WIDTH_reg-1:WIDTH_reg-24]; 
  
endmodule : FIR

