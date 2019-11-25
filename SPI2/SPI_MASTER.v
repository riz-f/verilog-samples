module SPI_MASTER
#( 
parameter   N = 16,
			DATA_WIDTH = 5
)
(
    input wire clk, enable,
    input wire [N-1:0] in_data, 
    output reg sclk, cs, mosi
); 

localparam 	s_reset = 0, 
			s_start = 1,
			s_store = 2,
			s_shift = 3;
    
reg[2:0] state_reg, state_next;  
reg[N-1:0] shift_data;
reg[DATA_WIDTH-1:0] bits_shifted;
reg bit_capture;


always @(posedge clk) 
begin
	if (state_reg == s_reset)
	begin
		shift_data <= 0;
		bits_shifted <= 0;
		bit_capture <= 0;
	end
	
	state_reg <= state_next;
	if (state_reg != state_next)
	begin
		if (state_next == s_start)
		begin
			shift_data <= in_data;
		end
		else
		if (state_next == s_store)
		begin
			bit_capture <= 1'b0; // miso
			bits_shifted <= bits_shifted + 1;
		end
		else
		if (state_next == s_shift)
			shift_data <= {shift_data[N-2:0], bit_capture}; 

	end
end 


always @*
begin 
    state_next = state_reg; 

	case (state_reg)
        s_reset : 
		begin
            sclk = 1'b0;
			cs = 1'b1;
			mosi = 1'b0;
            if (enable) 
			begin  
                state_next = s_start; 
            end
		end
		  
        s_start : 
		begin
			sclk = 1'b0;
			cs = 1'b0;
			mosi = shift_data[N-1];
			state_next = s_store; 
        end
		  
        s_store : 
		begin
			sclk = 1'b1;
			cs = 1'b0;
			mosi = shift_data[N-1];	
			if (bits_shifted < N) state_next = s_shift; 
			else state_next = s_reset;	
		end
		  
		s_shift : 
		begin
			sclk = 1'b0;
			cs = 1'b0;
			mosi = shift_data[N-1];
			state_next = s_store; 
        end
    endcase
	
end 


endmodule