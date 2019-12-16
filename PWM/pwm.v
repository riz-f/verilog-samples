module PWM
#( 
	parameter
	N = 8,
	DATA_WIDTH = $clog2(N),
	C_FULL = 8'b11111111,
	C_ZERO = 8'b00000000
)
(
    input clk,
    input [N-1:0] PWM_in,
    output PWM_out 
);

localparam DIVISOR = 2;

assign clk_reduced = (counter<DIVISOR/2)?1'b0:1'b1;

reg[31:0] counter;

always @(posedge clk)
begin
	counter <= counter + 1;
	if(counter>=(DIVISOR-1))
		counter <= 0;
end

reg [N-1:0] cnt;
reg cnt_dir;
wire [N-1:0] cnt_next;
wire cnt_end;

assign cnt_next = cnt_dir ? cnt - 1'b1 : cnt + 1'b1;

assign cnt_end = cnt_dir ? cnt == C_ZERO : cnt == C_FULL;


always @(posedge clk_reduced) cnt <= cnt_end ? PWM_in : cnt_next;

always @(posedge clk_reduced) cnt_dir <= cnt_dir ^ cnt_end;

assign PWM_out = cnt_dir;

endmodule