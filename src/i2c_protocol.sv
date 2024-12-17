module i2c_protocol (
   input  logic         clk      ,
   input  logic         reset_n  ,
   input  logic         start    , 
   input  logic [6:0]   addr     ,
   input  logic         wr_rd    ,
   input  logic [7:0]   data_st  ,
   input  logic [7:0]   data_nd  ,
   
   output logic busy             ,
   output logic done             ,

   inout        sclk             ,
   inout        sdin 
);

   logic [ 6:0]   addr_send;
   logic [ 7:0]   data_st_send,
                  data_nd_send;
   logic          wr_rd_send;
   logic          done_tmp,
                  busy_tmp,
                  sclk_tmp,
                  sdin_tmp;

   logic [  4:0]  count_q,
                  count_d;
   logic [26:0]   data;
   assign data = {addr_send, wr_rd_send, 1'b1, data_st_send, 1'b1, data_nd_send, 1'b1}; // 2-wire serial interface 

   typedef enum logic [4:0] {
      IDLE        , 
      START       ,
      START_CONT  ,
      BUF_1       ,
      DATA_SEND_1 ,
      DATA_SEND_2 ,
      DATA_SEND_3 ,
      DATA_SEND_4 ,
      BUF_2       ,
      STOP        ,
      DONE
   } state_e;

   state_e state_d;
   state_e state_q; 

   always @(posedge start) begin 
      addr_send      <= addr;
      data_st_send   <= data_st;
      data_nd_send   <= data_nd;
      wr_rd_send     <= wr_rd;
   end

   // state transition
   always_ff @(posedge clk or negedge reset_n) begin 
      if (!reset_n) begin 
         state_q <= IDLE; // reset state
         count_q <= 5'd27;
      end else begin 
         state_q <= state_d; // next state <= presen state
         count_q <= count_d; // counter cycle 
      end
   end

   // output state transition
   always_comb begin 
      case (state_q) 
         IDLE: begin 
            if (start)  state_d = START;
            else        state_d = state_q;

            sclk_tmp = 1; 
            sdin_tmp = 1;
            count_d  = 5'd26;
            done     = 0;
            busy     = 0;
         end
         START: begin 
            state_d  = START_CONT;
            count_d  = count_q;
            sclk_tmp = 1;
            sdin_tmp = 0;
            done     = 0;
            busy     = 1;
         end
         START_CONT: begin 
            state_d  = BUF_1;
            count_d  = count_q;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         BUF_1: begin 
            state_d  = DATA_SEND_1;
            count_d  = count_q;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_1: begin 
            state_d  = DATA_SEND_2;
            count_d  = count_q;
            sclk_tmp = 0;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_2: begin 
            state_d  = DATA_SEND_3;
            count_d  = count_q;
            sclk_tmp = 1;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_3: begin 
            state_d  = DATA_SEND_4;
            count_d  = count_q;
            sclk_tmp = 1;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_4: begin 
            count_d = count_q - 1;
            if (count_q == 0) state_d = BUF_2;
            else              state_d = DATA_SEND_1;
            sclk_tmp = 0;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         BUF_2: begin 
            state_d  = STOP;
            count_d  = 26;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         STOP: begin 
            state_d  = DONE;
            count_d  = 5'd26;
            sclk_tmp = 1;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         DONE: begin 
            state_d  = IDLE;
            count_d  = 26;
            sclk_tmp = 1;
            sdin_tmp = 1;
            busy     = 1;
            done     = 1;
         end
         default: begin
            state_d  = IDLE;
            count_d  = 26;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 0;
            done     = 0;
         end
      endcase
   end

   assign sclk = (sclk_tmp) ? 1'b1 : 1'b0;
   assign sdin = (sdin_tmp) ? 1'bz : 1'b0;

endmodule 