module top
(
	input clk, 
	output scl, sda
);

localparam DIVISOR = 64;

assign clk_reduced = (counter<DIVISOR/2)?1'b0:1'b1;

reg[31:0] counter;

I2C_MASTER m_1 (.clk(clk_reduced), .in_data(8'b10100000), .scl(scl), .sda(sda));

always @(posedge clk)
begin
	counter <= counter + 1;
	if(counter>=(DIVISOR-1))
		counter <= 0;
end


endmodule 
