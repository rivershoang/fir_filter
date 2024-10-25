`timescale 1ns / 1ps

module i2c_tb;

   // Khai báo các tín hiệu cho testbench
   logic clk;
   logic is_send;
   logic [7:0] i2c_addr;
   logic [15:0] i2c_data;
   logic is_done;
   logic is_busy;
   logic sclk;
   tri sdin;

   // Tạo instance của module I2C
   i2c dut (
      .clk(clk),
      .is_send(is_send),
      .i2c_addr(i2c_addr),
      .i2c_data(i2c_data),
      .is_done(is_done),
      .is_busy(is_busy),
      .sclk(sclk),
      .sdin(sdin)
   );

   // Khởi tạo tín hiệu clock 50MHz
   initial begin
      clk = 0;
      forever #10 clk = ~clk; // Clock 50MHz với chu kỳ 20ns
   end
   
   // Tạo các kiểm tra testbench
   initial begin
      // Reset các tín hiệu đầu vào
      is_send = 0;
      i2c_addr = 8'b00110100;
      i2c_data = 16'b0000111_00001_1011;
      
      // Đợi vài chu kỳ clock để khởi động
      #100;

      // Test 1: Bắt đầu gửi dữ liệu qua I2C
      i2c_addr = 8'b00110100;  // Địa chỉ I2C
      i2c_data = 16'b0000111_00001_1011; // Dữ liệu cần gửi
      is_send = 1; // Bắt đầu gửi
      #20; // Đợi một vài chu kỳ

      // Chờ trạng thái busy
      wait(is_busy == 1);
      #20;

      // Đợi cho đến khi dữ liệu được gửi xong
      wait(is_done == 1);
      #20;

      // Kiểm tra kết quả
      if (is_done) begin
         $display("I2C Transmission Completed Successfully.");
      end else begin
         $display("I2C Transmission Failed.");
      end

      // Kết thúc quá trình mô phỏng
      #100;
      $stop;
   end
endmodule
