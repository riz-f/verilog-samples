module DAC 
(
	input clk,
	input [7:0] data,
	
	output din,
	output ldac,
	output sync,
	output isclk,
	output clr,
	output sclk
);

wire en;
reg [6:0] counter;

SPI_MASTER spi (.clk(clk), .enable(en), .in_data({4'b1000, data, 4'b0000}), .sclk(isclk), .cs(sync), .mosi(din));

always @(negedge clk)
begin
	if (counter == 35)
		counter = 0;
	else
		counter = counter + 1; 
end

assign en = (counter == 0);
assign ldac = ~(counter == 34);
assign clr = 1'b1;
assign sclk = ~isclk;

endmodule 