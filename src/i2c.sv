module i2c (
   input  logic        clk,
   input  logic        is_send ,
   input  logic [ 7:0] i2c_addr,
   input  logic [15:0] i2c_data,
   output logic        is_done ,
   output logic        is_busy ,
   output logic        sclk    ,
   inout  wire         sdin
);

   logic       clk_i2c = 0;
   logic       is_ack_en = 0;
   logic       is_clk_low = 0;
   logic       en_i2c_clk = 0; 
   logic       ack_send = 0; 
   integer     counter_clock; 
   logic [3:0] count_bit = 0;

   typedef enum logic [3:0] {
      IDLE, 
      START,
      ADDRESS,
      ACK_1,
      FIRST_DATA,
      ACK_2,
      SECOND_DATA,
      ACK_3,
      STOP
   } state_e;
   state_e state = IDLE; 

   // Create 200khz clock i2c
   always_ff @(posedge clk) begin 
      if (counter_clock < 250) counter_clock <= counter_clock + 1;
      else counter_clock <= 0;
      // clock i2c 100Khz
      clk_i2c <= (counter_clock < 125) ? 1'b1 : 1'b0;
      // singal ack enable when sclk HIGH 
      is_ack_en <= (counter_clock == 62) ? 1'b1 : 1'b0; // make sure sclk HIGH
      // singal when sclk LOW 
      is_clk_low <= (counter_clock == 187) ? 1'b1 : 1'b0; // make sure sclk LOW
   end

   // Data transfer 
   always_ff @(posedge clk) begin
      if (en_i2c_clk) sclk <= clk_i2c; // clock i2c has been created
      else sclk <= 1; // high

      // when sclk LOW 
      if (is_clk_low) begin
         case (state) 
         IDLE: begin 
            sdin       <= 1'b1;
            is_busy    <= 0;
            is_done    <= 0;
            if (is_send) begin 
               state   <= START;
               is_busy <= 1; 
            end
         end
         START: begin 
            sdin      <= 1'b0; 
            count_bit <= 4'd7;
            state     <= ADDRESS;
         end
         ADDRESS: begin
            en_i2c_clk <= 1;
            // send 8 bit address
            if (count_bit > 0) begin 
               sdin       <= i2c_addr[count_bit];
               count_bit  <= count_bit - 1;
            end else begin 
               sdin      <= i2c_addr[count_bit]; // bit 0 (rd/write bit)
               ack_send  <= 1;
            end
            // send ack 
            if (ack_send) begin 
               ack_send  <= 0; // reset for next ack 
               sdin      <= 1'bz; // receive data from slave
               state     <= ACK_1;
            end
         end
         FIRST_DATA: begin 
            if (count_bit > 8) begin  // send data bit 15-8
               sdin      <= i2c_data[count_bit];
               count_bit <= count_bit - 1;
            end else begin 
               sdin      <= i2c_data[count_bit]; // last bit (8) 
               ack_send  <= 1;
            end
            // 2nd ack send
            if (ack_send) begin
               sdin      <= 1'bz;
               ack_send  <= 0;
               state     <= ACK_2;
            end
         end
         SECOND_DATA: begin 
            if (count_bit > 0) begin  // send data bit 7-0
               sdin      <= i2c_data[count_bit];
               count_bit <= count_bit - 1;
            end else begin 
               sdin      <= i2c_data[count_bit]; // last bit (8) 
               ack_send  <= 1;
            end
            // 3nd ack send
            if (ack_send) begin 
               sdin      <= 1'bz;
               ack_send  <= 0;
               state     <= ACK_3;
            end
         end
         STOP: begin 
            en_i2c_clk <= 0; // mean sclk high (Stop)
            sdin       <= 1'b0; // sdin_temp w when sclk high -> stop 
            is_done    <= 1;
            state      <= IDLE;
         end
         default: ;
         endcase 
      end
      // state for send ack
      if (is_ack_en) begin
         case (state) 
         ACK_1: begin 
            if (sdin == 0) begin // mean ack 
            count_bit <= 4'd15; // send bit 15-8 
            state     <= FIRST_DATA; 
            end else begin // nack
               en_i2c_clk <= 0; // mean sclk high 
               state      <= IDLE; // send data again
            end
         end
         ACK_2: begin
            if (sdin == 0) begin // mean ack 
            count_bit <= 4'd7; // send bit 7-0 
            state     <= SECOND_DATA; 
            end else begin // nack
               en_i2c_clk <= 0; // mean sclk high 
               state      <= IDLE; // send data again
            end
         end
         ACK_3: begin 
            if (sdin == 0) begin // mean ack  
            state <= STOP; // done  
            end else begin // nack
               en_i2c_clk <= 0; // mean sclk high 
               state      <= IDLE; // send data again
            end
         end
         default: ;
         endcase 
      end
   end 

endmodule : i2c
      
   






