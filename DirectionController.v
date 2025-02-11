module DirectionController
(
	input	clk, rstn, turn_right, turn_left,
	output reg [3:0] data_out // bit 0: x (column) count_enable,
	                          // bit 1: x (column) updown,
	                          // bit 2: y (row) count_enable,
	                          // bit 3: y (row) updown
);
	
	// Signal declaration
	reg [1:0] state_reg, state_next;
				
	// Declare states
	localparam [1:0] stop = 2'b00, 
	                 left = 2'b01, 
					 right = 2'b10;
	
	// state register
	always@(posedge clk, negedge rstn)
		if(!rstn)
			state_reg <= stop;
		else
			state_reg <= state_next;
	
	// Moore Output depends only on the state
	always @ (state_reg) 
	begin
		case(state_reg)
			stop:
				data_out = 4'b0000;
			left:
				data_out = 4'b0011;
			right:
				data_out = 4'b0001;
				
			default:
				data_out = 4'b0000;
		endcase
	end
		
	// Determine the next state
	always @ *
	begin
		case(state_reg)
			stop:
				if(turn_right) state_next = left;
				else if(turn_left) state_next = right;
				else state_next = stop;
			left:
				if(turn_right) state_next = left;
				else(turn_left) state_next = stop;	
			right:
				if(turn_right) state_next = stop;
				else(turn_left) state_next = right;

			default:
				state_next = stop;
		endcase
	end
endmodule