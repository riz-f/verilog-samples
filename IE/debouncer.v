module debounce
#(
	parameter bounce_limit = 600000
)
(
	input clk,
	input switch_in,
	output reg switch_out,
	output reg switch_rise,
	output reg switch_fall
);



reg [$clog2(bounce_limit):0] bounce_count = 0;

reg [1:0] switch_shift = 0;
always @(posedge clk)
	switch_shift <= {switch_shift,switch_in};

always @(posedge clk)
begin
	if (bounce_count == 0)
	begin
		switch_rise <= switch_shift == 2'b01;
		switch_fall <= switch_shift == 2'b10;
		switch_out <= switch_shift[0];
		if (switch_shift[1] != switch_shift[0])
			bounce_count <= bounce_limit;
	end
	else
	begin
		switch_rise <= 0;
		switch_fall <= 0;
		bounce_count <= bounce_count-1;
	end
end




endmodule
