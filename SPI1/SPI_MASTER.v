module SPI_MASTER
#( parameter
	N = 8,
	DATA_WIDTH = 3
)
(
    input wire clk, reset, 
    input wire [N-1:0] in_data, 
    output reg sclk, cs, mosi
);

 
localparam 	s_reset = 0, 
			s_load_cs = 1,
			s_load = 2,
			s_store = 3,
			s_shift = 4,
			T1 = 3,
			T2 = 1;
				
reg[2:0] state_reg, state_next;  
reg[2:0] t; 
reg[N-1:0] shift_data;
reg[DATA_WIDTH-1:0] bits_shifted;
reg bit_capture;

always @(posedge clk, posedge reset) begin
	if (reset) 
	begin
		state_reg <= s_reset;
	end
	else 
	begin
		state_reg <= state_next;
	end
end 

always @(posedge clk) 
begin 
	if (state_reg == s_reset)
	begin
		t <= 0;
		shift_data <= 0;
		bits_shifted <= 0;
	end

	if (state_reg != state_next)
	begin
		t <= 0;
		if (state_next == s_shift)
		begin
			shift_data <= {shift_data[N-2:0], bit_capture};
			bits_shifted <= bits_shifted + 1;
		end
		else 
		if (state_next == s_load)
			shift_data <= in_data;
		else
		if (state_next == s_store)
			bit_capture <= 1'b0;	//miso
	end
	else
	begin
		t <= t + 1;  
	end
	
end 
        
always @(bits_shifted, state_reg, t) begin 
	state_next = state_reg;
	case (state_reg)

		s_reset : 
		begin
			if ( t >= T1) 
			begin  
				state_next = s_load_cs; 
			end
		end

		s_load_cs : 
		begin
			if (t >= T2) 
			begin 
				state_next = s_load; 
			end
		end

		s_load : 
		begin
			if (t >= T2) 
			begin 
				state_next = s_store; 
			end	
		end

		s_store : 
		begin	

			if ( (t >= T2) && (bits_shifted < (N-1) ) ) 
			begin 
				state_next = s_shift; 
			end
			else
				if ( (t >= T2) && (bits_shifted >= (N-1)) ) 
				begin 
					state_next = s_reset; 
				end	
		end

		s_shift : 
		begin

			if (t >= T2) 
			begin 
				state_next = s_store; 
			end

		end

	endcase
end 
    

always @(state_reg, shift_data) 
begin
   
	case (state_reg)  
		s_reset : 
		begin
			cs = 1'b1 ;
			sclk = 1'b0;
			mosi = 1'b0;
		end

		s_load_cs : 
		begin
			cs = 1'b0;
			sclk = 1'b0;
			mosi = 1'b0;
		end

		s_load : 
		begin
			cs = 1'b0 ;
			sclk = 1'b1;
			mosi = shift_data[7];
		end

		s_store : 
		begin
			cs = 1'b0 ;
			sclk = 1'b0;
			mosi = shift_data[7];								
		end

		s_shift : 
		begin
			cs = 1'b0 ;
			sclk = 1'b1;
			mosi = shift_data[7];
		end

	endcase
end 

initial
begin 
	t <= 0;
end


endmodule 
