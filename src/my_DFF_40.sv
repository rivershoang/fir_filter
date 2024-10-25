module my_DFF_40 #(
    parameter WIDTH_reg =  40
)
    (
    input logic         clk, 
    input logic         rst_n,
    input logic signed [WIDTH_reg-1:0]  d_in,
    output logic signed [WIDTH_reg-1:0] q_out
);

always_ff@(posedge clk) begin 
    if (!rst_n) begin 
        q_out <= 0;
    end
    else begin 
        q_out <= d_in; 
    end
end

endmodule: my_DFF_40