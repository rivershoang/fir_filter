module paralell_serial (
   input  logic         clk_12M,
   input  logic         start,
   input  logic [23:0]  data_paralell,

   output logic         data_serial,
   output logic         bclk,
   output logic         lrclk,
   output logic         clk_fsample
);

   typedef enum logic [4:0] {
      IDLE,
      LEFT_READY,
      LEFT_SEND_1,
      LEFT_SEND_2,
      STOP_LEFT,
      RIGHT_READY,
      RIGHT_SEND_3,
      RIGHT_SEND_4,
      STOP_RIGHT
   } state_e;

   state_e state_q;
   state_e state_d;

   logic [23:0]   data_paralell_pre;
   logic [ 8:0]   count_d,
                  count_q;
   logic [ 4:0]   count_bit_d,
                  count_bit_q;
   logic          lrck_tmp;

   always_ff @(posedge clk_fsample) begin 
      data_paralell_pre <= data_paralell;
   end

   always_ff @(posedge clk_12M) begin 
      state_q     <= state_d;
      count_q     <= count_d;
      count_bit_q <= count_bit_d;
   end

   always_comb begin 
      case (state_q)
         IDLE: begin 
            if (start)  state_d = LEFT_READY;
            else        state_d = state_q;
            bclk        = 1;
            count_bit_d = 5'd23;
            count_d     = 0;
            lrck_tmp    = 0;
         end
         LEFT_READY: begin 
            state_d     = LEFT_SEND_1;
            bclk        = 1;
            count_bit_d = 5'd23;
            count_d     = count_q + 1;
            lrck_tmp    = 1;
         end
         LEFT_SEND_1: begin 
            state_d     = LEFT_SEND_2;
            bclk        = 0;
            count_bit_d = count_bit_q;
            count_d     = count_q + 1;
            lrck_tmp    = 1;
         end
         LEFT_SEND_2: begin 
            if (count_bit_q == 0) begin 
               state_d     = STOP_LEFT;
               count_bit_d = 5'd23;
            end else begin 
               state_d     = LEFT_SEND_1;
               count_bit_d = count_bit_q - 1;
            end
            count_d  = count_q + 1;
            bclk     = 1;
            lrck_tmp = 1;
         end
         STOP_LEFT: begin 
            if (count_q == 130) begin
               state_d     = RIGHT_READY;
               count_bit_d = 5'd23;
            end else begin 
               state_d     = state_q;
               count_bit_d = 5'd23;
            end
            count_d  = count_q + 1;
            bclk     = 0;
            lrck_tmp = 1;
         end
         RIGHT_READY: begin
            state_d     = RIGHT_SEND_3;
            count_bit_d = 5'd23;
            bclk        = 1;
            count_d     = count_q + 1;
            lrck_tmp    = 0;
         end
         RIGHT_SEND_3: begin 
            state_d     = RIGHT_SEND_4;
            bclk        = 0;
            count_bit_d = count_bit_q;
            count_d     = count_q + 1;
            lrck_tmp    = 0;
         end
         RIGHT_SEND_4: begin 
            if (count_bit_q == 0) begin 
               state_d     = STOP_RIGHT;
               count_bit_d = 5'd23;
            end else begin 
               state_d     = RIGHT_SEND_3;
               count_bit_d = count_bit_q - 1;
            end
            count_d  = count_q + 1;
            bclk     = 1;
            lrck_tmp = 0;
         end
         STOP_RIGHT: begin 
            if (count_q == 260) begin 
               state_d = LEFT_READY;
               count_d = 0;
            end else begin 
               state_d = state_q;
               count_d = count_q + 1;
            end
            count_bit_d = 23;
            bclk        = 0;
            lrck_tmp    = 0;
         end
         default: begin 
            state_d     = IDLE;
            bclk        = 0;
            count_bit_d = 0;
            count_d     = 0;
            lrck_tmp    = 0;
         end
      endcase 
   end

   assign data_serial   = data_paralell_pre[count_bit_q];
   assign lrclk         = lrck_tmp;
   assign clk_fsample   = lrck_tmp;

endmodule 
      
      
