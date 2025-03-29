module i2c_protocol_tb;

    // Inputs
    logic clk;
    logic reset_n;
    logic start;
    logic [6:0] addr;
    logic wr_rd;
    logic [7:0] data_st;
    logic [7:0] data_nd;

    // Outputs
    logic busy;
    logic done;

    // Bidirectional signals
    wire sclk;
    wire sdin;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // DUT instantiation
    i2c_protocol dut (
        .clk    (clk)       ,
        .reset_n(reset_n)   ,
        .start  (start)     ,
        .addr   (addr)      ,
        .wr_rd  (wr_rd)     ,
        .data_st(data_st)   ,
        .data_nd(data_nd)   ,
        .busy   (busy)      ,
        .done   (done)      ,
        .sclk   (sclk)      ,
        .sdin   (sdin)
    );

    // Testbench logic
    initial begin
        // Initialize inputs
        reset_n = 0;
        start = 0;
        addr = 7'h00;
        wr_rd = 0;
        data_st = 8'h00;
        data_nd = 8'h00;

        // Apply reset
        #20;
        reset_n = 1;

        @(posedge clk);
        addr = 7'h55;
        wr_rd = 0; // Write operation
        data_st = 8'hA5;
        data_nd = 8'h5A;
        start = 1;
        @(posedge clk);
        start = 0;

        #5000;
        $stop;
    end

endmodule