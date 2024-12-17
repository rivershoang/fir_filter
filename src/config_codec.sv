module config_codec (
   input  logic         clk         ,
   input  logic         reset_n     ,
   input  logic         busy        ,
   input  logic         is_config   ,
   
   output logic         done_config ,
   output logic         ack_i2c     ,
   output logic         wr_rd       ,
   output logic [6:0]   addr        ,
   output logic [7:0]   addr_reg    ,
   output logic [7:0]   data_config 
);

   logic [15:0] data_array [9:0]; 

   always_ff @(negedge reset_n) begin 
      data_array[0] <= 16'h1e00; //reset all
      data_array[1] <= 16'h0c00; //PWU
      data_array[2] <= 16'h0579; //LV //add: 0000 010 data: 1 0111 1001
      data_array[3] <= 16'h0779; //RV
      data_array[4] <= 16'h0e09; //addr: 0000 111 data: 0 0000 1001
      data_array[5] <= 16'h1001; //addr: 0001 000 data: 0 0000 0001
      data_array[6] <= 16'h13ff; //active
      data_array[7] <= 16'h0812; //addr: 0000 100 data: 0 0001 0010
      data_array[8] <= 16'h0a00; //addr: 0000 101 data: 0 0000 0000
      data_array[9] <= 16'h0a00;
  end

   typedef enum logic [3:0] {
      IDLE,
      IS_CONFIG,
      SEND_1,
      SEND_2,
      IS_READY,
      SEND_LAST,
      DONE
   } state_e;

   state_e state_q;
   state_e state_d;

   logic [3:0] count_d,
               count_q;

   logic       temp_ack_i2c,
               done;

   logic [15:0] data_temp;

   assign data_temp     = data_array[count_q];
   assign addr_reg      = data_temp[15:8];
   assign data_config   = data_temp[7:0];

   always_ff @(posedge clk or negedge reset_n) begin 
      if (!reset_n) begin 
         state_q <= IDLE;
         count_q <= 0;
      end else begin 
         state_q <= state_d;
         count_q <= count_d;
      end
   end

   always_comb begin 
      case (state_q)
         IDLE: begin 
            if (~busy)  state_d = IS_CONFIG;
            else        state_d = state_q;
            count_d        = 0;
            temp_ack_i2c   = 0;
            done           = 0;
         end
         IS_CONFIG: begin 
            if ((~is_config) && (~busy))  state_d = SEND_1;
            else                          state_d = state_q;
            count_d        = count_q;
            temp_ack_i2c   = 0;
            done           = 0;
         end 
         SEND_1: begin 
            state_d        = SEND_2;
            count_d        = count_q;
            temp_ack_i2c   = 1;
            done           = 0;
         end
         SEND_2: begin 
            state_d        = IS_READY;
            count_d        = count_q;
            temp_ack_i2c   = 1;
            done           = 0;
         end
         IS_READY: begin 
            if (~busy)  state_d = SEND_LAST;
            else        state_d = state_q; 
            count_d        = count_q;
            temp_ack_i2c   = 0;
            done           = 0;
         end
         SEND_LAST: begin 
            if (count_q == 9) state_d = DONE;
            else              state_d = IS_CONFIG;
            count_d        = count_q + 1;
            temp_ack_i2c   = 0;
            done           = 0;
         end
         DONE: begin 
            state_d        = state_q;
            count_d        = 0;
            temp_ack_i2c   = 0;
            done           = 1;
         end
         default: begin 
            state_d        = IDLE;
            count_d        = 0;
            temp_ack_i2c   = 0;
            done           = 0;
         end
      endcase 
   end

   assign addr          = 7'b0011010;
   assign wr_rd         = 1'b0;
   assign done_config   = done;
   assign ack_i2c       = temp_ack_i2c;
   
endmodule 
