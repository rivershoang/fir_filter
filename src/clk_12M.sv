module clk_12M (
    input  wire reset_n,
    input  wire clk_in,      
    output reg clk_out     
);
   reg [5:0] counter;
   always @(posedge clk_in, negedge reset_n) begin
      if (!reset_n) begin
         clk_out <= 0;
         counter <= 0;
      end
      else if (counter == 1) begin
            clk_out <= ~clk_out; 
            counter <= 0;
         end 
      else begin
         counter <= counter + 6'd1; 
      end
   end
   
endmodule