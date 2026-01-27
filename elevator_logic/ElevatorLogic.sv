module ElevatorLogic #(
    parameter MAXFLOORS = 10,
    parameter MINFLOORS = 0
) (
    input logic clk_i,
    input logic rst_i,
    input logic request_i,
    input logic[3:0] requested_current_floor_i,
    input logic[3:0] requested_destination_floor_i,
    output logic[3:0] floor_o,
    output logic[1:0] direction_o,
    output logic request_served_o
);


localparam GOING_UP = 2'b11;
localparam GOING_DOWN = 2'b00;
localparam STATIONARY = 2'b01;
localparam N_FLOORS = MAXFLOORS-MINFLOORS;

typedef enum bit[1:0] {state_stationary, state_up, state_down} state_t;
state_t current_state, next_state;
logic[3:0] current_floor;
logic [1:0] prev_direction_q0, prev_direction_q1;
logic[N_FLOORS-1:0] pressed_buttons;

always_ff @(posedge clk_i) begin 
    if (rst_i == 1'b0) begin
        current_floor <= '0;
        current_state <= state_stationary;
        next_state <= state_stationary;
        pressed_buttons <= '0;
        prev_direction_q0 <= '0;
        prev_direction_q1 <= '0;
    end else begin
        current_state <= next_state;
        if(current_floor == requested_current_floor_i && current_state == state_stationary) begin // button is pressed only when person enters the elevator.
            pressed_buttons[requested_destination_floor_i] <= 1'b1;
        end else if (pressed_buttons[current_floor+1] == 1'b1 && current_state == state_up ) begin // button is de-pressed once the person steps out of the elevator. Compensate for 1 clk delay
            pressed_buttons[current_floor+1] = 1'b0;
        end else if (pressed_buttons[current_floor-1] == 1'b1 && current_state == state_down) begin // button is de-pressed once the person steps out of the elevator. Compensate for 1 clk delay
            pressed_buttons[current_floor-1] = 1'b0;
        end else pressed_buttons <= pressed_buttons;

        prev_direction_q0 <= direction_o; // what direction the elevator was moving before stopping (retain for two clks)
        prev_direction_q1 <= prev_direction_q0; 

        // current_floor manipulations 
        if (current_state == state_stationary) current_floor <= current_floor;
        else if (current_state == state_up) current_floor <= current_floor + 1'd1;
        else  current_floor <= current_floor - 1'd1;
    end
end

always_comb begin : state_update
    case (current_state)
        state_stationary : begin
            if (| pressed_buttons == 1'b0 && request_i == 1'b0 ) begin // there are no pressed button and no requests made
                next_state = state_stationary;
            end else if (| pressed_buttons == 1'b0 && request_i == 1'b1 ) begin // there is new request
                if (requested_current_floor_i < current_floor) next_state = state_down;
                else if (requested_current_floor_i > current_floor) next_state = state_up;
                else next_state = state_stationary;                
            end else begin
                if (prev_direction_q1 == GOING_UP) next_state = state_up;
                else if (prev_direction_q1 == GOING_DOWN) next_state = state_down;
                else next_state = state_stationary;
            end
        end
        state_up : begin
            if (pressed_buttons[current_floor+1] == 1'b1 || requested_current_floor_i == current_floor+1) begin
                next_state = state_stationary;
            end else next_state = state_up;
        end
        state_down : begin
            if (pressed_buttons[current_floor-1] == 1'b1 || requested_current_floor_i == current_floor-1) begin
                next_state = state_stationary;
            end else next_state = state_down;
        end
        default: 
            next_state = state_stationary;
    endcase
    
end

always_comb begin : output_block
    case(current_state)
        state_stationary : begin
            direction_o = STATIONARY;
            request_served_o = (current_floor == requested_current_floor_i) ? 1'b1 : 1'b0;
            floor_o = current_floor;
        end
        state_up : begin
            direction_o = GOING_UP;
            request_served_o = 1'b0;
            floor_o = current_floor;
        end
        state_down : begin
            direction_o = GOING_DOWN;
            request_served_o = 1'b0;
            floor_o = current_floor;
        end
        default : begin
            direction_o = STATIONARY;
            request_served_o = 1'b1;
            floor_o = current_floor;
        end
    endcase
end



endmodule