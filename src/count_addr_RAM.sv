module count_addr_RAM (
   input             clk      ,
   input             reset_n  ,
   output reg [15:0] addr
);

   always @(posedge clk or negedge reset_n) begin
      if(!reset_n) begin
         addr <= 15'd0;
      end else begin 
         if (addr < 1000) addr <= addr + 15'd1;
         else            addr <= 15'd0;
      end
   end
   
endmodule