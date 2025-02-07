// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)

module DirectionController
(
	input	clk, rstn, turn_right, turn_left,
	output reg [1:0] data_out // bit 0: y (row) count_enable,
	                          // bit 1: y (row) updown (1 = up, 0 = down)
);
	
	// Signal declaration
	reg state_reg, state_next;
				
	// Declare states
	localparam UP = 1'b0, 
	           DOWN = 1'b1;
	
	// state register
	always@(posedge clk, negedge rstn)
		if(!rstn)
			state_reg <= UP;
		else
			state_reg <= state_next;
	
	// Moore Output depends only on the state
	always @ (state_reg) 
	begin
		case(state_reg)
			UP:
				data_out = 2'b11; // Enable count, move up
			DOWN:
				data_out = 2'b10; // Enable count, move down
			default:
				data_out = 2'b11;
		endcase
	end
		
	// Determine the next state
	always @ *
	begin
		case(state_reg)
			UP:
				if(turn_left) state_next = DOWN;
				else state_next = UP;
				
			DOWN:
				if(turn_right) state_next = UP;
				else state_next = DOWN;
				
			default:
				state_next = UP;
		endcase
	end
endmodule
