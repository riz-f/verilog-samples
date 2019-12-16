module I2C_MASTER
#( 
	parameter
	N = 8,
	DATA_WIDTH = $clog2(N)
)
(
	input wire clk, 
	input wire [N-1:0] in_data, 
	output reg scl, sda
);

localparam 	s_ready = 0, 
			s_start = 1,
			s_scl_low_front = 2,
			s_send = 3,
			s_scl_low_back  = 4,
			s_down = 5,
			s_scl_up = 6,
			s_stop = 7,

			STATES_AMOUNT = 8,
			TIME_WIDTH = 3,
			T_DEALY_ON_READY = 2,
			T_DEALY_ON_SEND = 1,
			MESSAGE_SIZE = N + 1;

				
reg[$clog2(STATES_AMOUNT)-1:0] state_reg, state_next;  
reg[TIME_WIDTH-1:0] time_count; 
reg[N-1:0] shift_data;
reg[DATA_WIDTH:0] bits_to_transfer;
reg[1:0] recive_acquire;

always @(posedge clk) 
begin 

	state_reg <= state_next;
	

	if (state_reg != state_next)
	begin
		
		time_count <= 0;
		
		case (state_next)
	
			s_scl_low_front : 
			begin
				if (bits_to_transfer == 0) 
					recive_acquire <= 1;
				else
				if (bits_to_transfer == N)
					shift_data <= in_data;
				else
					shift_data <= shift_data << 1;	
			end
		
			s_scl_low_back : 
			begin
				if ( bits_to_transfer != 0) 
					bits_to_transfer <= bits_to_transfer - 1;
			end
		
		endcase
	
	end
	else
	begin	
			time_count <= time_count + 1;
			if (state_reg == s_ready) 
			begin
				bits_to_transfer <= N;
				recive_acquire <= 0;
			end
	end
	
end 
        
always @* 
begin
	
	state_next = state_reg;	
	
	case (state_reg)
	
		s_ready : 
		begin
			sda = 1'b1;
			scl = 1'b1;
			if ( time_count >= T_DEALY_ON_READY ) 
			begin  
				state_next = s_start; 
			end
		end

		s_start : 
		begin
			sda = 1'b0;
			scl = 1'b1;			
			state_next = s_down; 
		end

		
		s_down :
		begin
			sda = 1'b0;
			scl = 1'b0;			
			if (bits_to_transfer == N)
				state_next = s_scl_low_front; 
			else
				state_next = s_scl_up; 
		end
		
		s_scl_low_front : 
		begin
			if (recive_acquire == 1)	
				sda =  1'bz; // ack bit recive
			else
				sda = shift_data[N-1];
			scl = 1'b0;
			state_next = s_send; 
		end

		s_send : 
		begin	
			if (recive_acquire == 1)	
				sda =  1'bz; // ack bit recive
			else
				sda = shift_data[N-1];
			scl = 1'b1;
			if ( time_count >= T_DEALY_ON_SEND ) 
			begin  
				state_next = s_scl_low_back; 
			end		
		end

		s_scl_low_back : 
		begin
			state_next = s_scl_low_front; 
			if (recive_acquire == 1)	
			begin
				sda =  1'bz; 
				state_next = s_down; 
			end
			else
				sda = shift_data[N-1];	
			scl = 1'b0;

		end
	
		s_scl_up : 
		begin
			sda = 1'b0;
			scl = 1'b1;
			state_next = s_ready; 
		end
		
	endcase
end 
    

endmodule 
