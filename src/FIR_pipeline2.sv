`timescale 1ps/1ps

module FIR_pipeline2 #(
    parameter   WIDTH_data =  24                      ,
                WIDTH_data_out = 48                   ,
                WIDTH_coeff = 16                      ,
                WIDTH_reg =   WIDTH_data + WIDTH_coeff,
                TAP =         52
) 
    (
    input logic                           clk,
    input logic                           reset_n,
    input logic signed [WIDTH_data-1:0]   data_in,
    output logic signed [WIDTH_data-1:0]  data_out
); 

// Araays --- 31 taps

    logic signed [WIDTH_reg-1:0] delay      [TAP-1:0]; // array for data_in delay
    logic signed [WIDTH_reg-1:0] pipeline   [TAP-1:0]; // array for data_in delay
    logic signed [WIDTH_reg-1:0] mul        [TAP-1:0]; // array for result multiply 
    logic signed [WIDTH_reg-1:0] add_out    [TAP-1:0]; // array for result addition
   // logic signed [WIDTH_coeff-1:0] h        [TAP-1:0];



    // store coeffs value
    // initial begin 
    //     $readmemh ("E:/Lecture/DSPonFPGA/FIR/mem/order_30_500_hex.txt", h);
    // end 

//    always_comb begin 
//        h[0]= 16'h0053 ; 
//        h[1]= 16'h0069 ;
//        h[2]= 16'h009B ;
//        h[3]= 16'h00EE ;
//        h[4]= 16'h0164 ;
//        h[5]= 16'h01FE ;
//        h[6]= 16'h02B8 ;
//        h[7]= 16'h038B ;
//        h[8]= 16'h0470 ;
//        h[9]= 16'h055A ;
//        h[10]= 16'h063D ;
//        h[11]= 16'h070E ;
//        h[12]= 16'h07BF ;
//        h[13]= 16'h0845 ;
//        h[14]= 16'h089A ;
//        h[15]= 16'h08B7 ;
//        h[16]= 16'h089A ;
//        h[17]= 16'h0845 ;
//        h[18]= 16'h07BF ;
//        h[19]= 16'h070E ;
//        h[20]= 16'h063D ;
//        h[21]= 16'h055A ;
//        h[22]= 16'h0470 ;
//        h[23]= 16'h038B ;
//        h[24]= 16'h02B8 ;
//        h[25]= 16'h01FE ;
//        h[26]= 16'h0164 ;
//        h[27]= 16'h00EE ;
//        h[28]= 16'h009B ;
//        h[29]= 16'h0069 ;
//        h[30]= 16'h0053 ;
//    end


//reg[15:0] h[50:0] = '{ 
//16'hFFE4, 16'hFFDD, 16'hFFE6, 16'h0001, 
//16'h002E, 16'h0057, 16'h005C, 16'h0024, 
//16'hFFB1, 16'hFF32, 16'hFEF9, 16'hFF50, 
//16'h0043, 16'h017C, 16'h0252, 16'h0213, 
//16'h006D, 16'hFDCA, 16'hFB53, 16'hFA9C, 
//16'hFCF7, 16'h02C5, 16'h0B1C, 16'h13E6, 
//16'h1A96, 16'h1D14, 16'h1A96, 16'h13E6, 
//16'h0B1C, 16'h02C5, 16'hFCF7, 16'hFA9C, 
//16'hFB53, 16'hFDCA, 16'h006D, 16'h0213, 
//16'h0252, 16'h017C, 16'h0043, 16'hFF50, 
//16'hFEF9, 16'hFF32, 16'hFFB1, 16'h0024, 
//16'h005C, 16'h0057, 16'h002E, 16'h0001, 
//16'hFFE6, 16'hFFDD, 16'hFFE4};

//reg[15:0] h[110:0] = '{ 
//16'h000F, 16'h000F, 16'h000F, 16'h000F, 16'h000F, 16'h000F, 16'h000E, 16'h000D, 16'h000B, 16'h0008, 
//16'h0004, 16'hFFFF, 16'hFFFA, 16'hFFF2, 16'hFFE9, 16'hFFDE, 16'hFFD3, 16'hFFC6, 16'hFFB8, 16'hFFAA, 
//16'hFF9D, 16'hFF8F, 16'hFF83, 16'hFF78, 16'hFF70, 16'hFF6B, 16'hFF6A, 16'hFF6E, 16'hFF76, 16'hFF85, 
//16'hFF9A, 16'hFFB5, 16'hFFD8, 16'h0002, 16'h0034, 16'h006D, 16'h00AE, 16'h00F5, 16'h0142, 16'h0195, 
//16'h01EC, 16'h0247, 16'h02A4, 16'h0301, 16'h035F, 16'h03BA, 16'h0412, 16'h0466, 16'h04B3, 16'h04F9, 
//16'h0537, 16'h056B, 16'h0594, 16'h05B2, 16'h05C5, 16'h05CB, 16'h05C5, 16'h05B2, 16'h0594, 16'h056B, 
//16'h0537, 16'h04F9, 16'h04B3, 16'h0466, 16'h0412, 16'h03BA, 16'h035F, 16'h0301, 16'h02A4, 16'h0247, 
//16'h01EC, 16'h0195, 16'h0142, 16'h00F5, 16'h00AE, 16'h006D, 16'h0034, 16'h0002, 16'hFFD8, 16'hFFB5, 
//16'hFF9A, 16'hFF85, 16'hFF76, 16'hFF6E, 16'hFF6A, 16'hFF6B, 16'hFF70, 16'hFF78, 16'hFF83, 16'hFF8F, 
//16'hFF9D, 16'hFFAA, 16'hFFB8, 16'hFFC6, 16'hFFD3, 16'hFFDE, 16'hFFE9, 16'hFFF2, 16'hFFFA, 16'hFFFF, 
//16'h0004, 16'h0008, 16'h000B, 16'h000D, 16'h000E, 16'h000F, 16'h000F, 16'h000F, 16'h000F, 16'h000F, 
//16'h000F};  

reg[15:0] h[51:0] = '{ 
16'hFFEC, 16'hFFDD, 16'hFFDD, 16'hFFF0, 
16'h0019, 16'h004A, 16'h0068, 16'h004E, 
16'hFFEF, 16'hFF66, 16'hFEFC, 16'hFF06, 
16'hFFB7, 16'h00E6, 16'h020B, 16'h0269, 
16'h0170, 16'hFF2A, 16'hFC68, 16'hFA9E, 
16'hFB54, 16'hFF76, 16'h06BF, 16'h0FA1, 
16'h17AC, 16'h1C74, 16'h1C74, 16'h17AC, 
16'h0FA1, 16'h06BF, 16'hFF76, 16'hFB54, 
16'hFA9E, 16'hFC68, 16'hFF2A, 16'h0170, 
16'h0269, 16'h020B, 16'h00E6, 16'hFFB7, 
16'hFF06, 16'hFEFC, 16'hFF66, 16'hFFEF, 
16'h004E, 16'h0068, 16'h004A, 16'h0019, 
16'hFFF0, 16'hFFDD, 16'hFFDD, 16'hFFEC}; 
    assign delay[0] = 0; // no delay 

    genvar i; 
    generate 
        for (i = 0; i < TAP; i = i + 1) begin: multi_datain_coeff 
                multi mult (
                .a(data_in),
                .b(h[i]),
                .out(mul[i])
            );
            end
            endgenerate 

    //
    genvar p; 
    generate 
        for (p = 0; p < TAP; p = p + 1) begin: pipeline_stage
                my_DFF_40 delay_e (
                .clk(clk),
                .rst_n(reset_n),
                .d_in(mul[p]),
                .q_out(pipeline[p])
            );
            end
            endgenerate 
    // 
    genvar k;
    generate 
        for (k=0; k < TAP; k = k + 1) begin: adder
            assign add_out[k] = pipeline[k] + delay[k];
            end
        endgenerate 

    //
    genvar j;
    generate 
        for (j=0; j < TAP - 1; j = j + 1) begin: delay_ztr1
            my_DFF_40 element (
                .rst_n(reset_n),
                .clk(clk),
                .d_in(add_out[j]),
                .q_out(delay[j+1])
            );
            end
            endgenerate
        // assign data_out = add_out[TAP-1][WIDTH_reg-1:WIDTH_reg-24]; 
            assign data_out = add_out[TAP-1][39:16];

endmodule 