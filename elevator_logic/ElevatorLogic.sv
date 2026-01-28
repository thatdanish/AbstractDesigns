module ElevatorLogic #(
    parameter MAXFLOORS = 10,
    parameter MINFLOORS = 0,
    parameter N_FLOORS = MAXFLOORS-MINFLOORS
) (
    input logic clk_i,
    input logic rst_i,
    input logic[N_FLOORS-1:0] request_down_i,
    input logic[N_FLOORS-1:0] request_up_i,
    input logic[3:0] requested_floor_i,
    output logic[3:0] floor_o,
    output logic[1:0] direction_o,
    output logic request_served_o
);

localparam GOING_UP = 2'b11;
localparam GOING_DOWN = 2'b00;
localparam STATIONARY = 2'b01;

typedef enum bit[1:0] {state_stationary=2'b00, state_up=2'b10, state_down=2'b01} state_t;
state_t current_state, next_state;
logic[3:0] current_floor;
logic[N_FLOORS-1:0] pressed_buttons;
logic[N_FLOORS-1:0] floor_enc;
logic active_request;

always_ff @(posedge clk_i) begin 
    if (rst_i == 1'b0) begin
        current_floor <= '0;
        current_state <= state_stationary;
        next_state <= state_stationary;
        active_request <= 1'b1;
        pressed_buttons <= '0;
        floor_enc <= '0;
    end else begin
        current_state <= next_state;
        
        // latching request
        active_request <= request_down_i[current_floor] || request_up_i[current_floor];
        
        // handling button presses
        if (pressed_buttons[current_floor] == 1'b1 && current_state == state_stationary) begin // button is de-pressed once the person steps out of the elevator.
            pressed_buttons[current_floor] = 1'b0;
        end else if (active_request && current_state == state_stationary) begin // button is pressed only when person enters the elevator.
            pressed_buttons[requested_floor_i] <= 1'b1;
        end else pressed_buttons <= pressed_buttons;

        // current_floor manipulations. Considering next_state to compensate for clk delay
        if (next_state == state_stationary) current_floor <= current_floor;
        else if (next_state == state_up) current_floor <= current_floor + 1'd1;
        else  current_floor <= current_floor - 1'd1;

        // floor encoding (shift registers)
        for(int k = 0; k < N_FLOORS; k++) begin
            if(k == current_floor) floor_enc[k] <= 1'b1;
            else floor_enc[k] <= 1'b0;
        end
    end
end

always_comb begin : state_update
    case (current_state)
        state_stationary : begin
            if (|(pressed_buttons) == 1'b0 && |(request_up_i) == 1'b0 && |(request_down_i) == 1'b0) begin // there are no pressed button and new no requests made
                next_state = state_stationary;
            end else if (|(pressed_buttons) == 1'b0 && |(request_up_i) == 1'b1 && |(request_down_i) == 1'b0) begin // there is new request to go up
                if (floor_enc > request_up_i) next_state = state_down;
                else if (floor_enc < request_up_i) next_state = state_up;
                else next_state = state_stationary;                
            end else if (|(pressed_buttons) == 1'b0 && |(request_up_i) == 1'b0 && |(request_down_i) == 1'b1) begin // there is new request to go down
                if (floor_enc > request_down_i) next_state = state_down;
                else if (floor_enc < request_down_i) next_state = state_up;
                else next_state = state_stationary;
            end else if ((|(pressed_buttons) == 1'b1 && pressed_buttons[current_floor] == 1'b0 && request_up_i[current_floor] == 1'b0 && request_down_i[current_floor] == 1'b0)) begin // there is/are pending requests and no new requests.
                if (floor_enc > pressed_buttons) next_state = state_down;
                else if (floor_enc < pressed_buttons) next_state = state_up;
                else next_state = state_stationary; // there are new and pending request. wait for new request to be registered.
            end
        end
        state_up : begin
            // Currently going up.
            // Go to stationary iff:
            // 1) there is a button pressed (destination reached). 2) ADDITIONAL UP request is received on the way up. 3) a NEW DOWN request is received.
            if (pressed_buttons[current_floor] == 1'b1 || request_up_i[current_floor] == 1'b1 || (request_down_i[current_floor]) == 1'b1 && |(pressed_buttons) == 1'b0 ) begin
                next_state = state_stationary;
            end else next_state = state_up;
        end
        state_down : begin
            // Currently going down.
            // Go to stationary iff:
            // 1) there is a button pressed (destination reached). 2) ADDITIONAL DOWN request is received on the way up. 3) a NEW UP request is received.
            if (pressed_buttons[current_floor] == 1'b1 || request_down_i[current_floor] == 1'b1 || (request_up_i[current_floor]) == 1'b1 && |(pressed_buttons) == 1'b0) begin
                next_state = state_stationary;
            end else next_state = state_down;
        end
        default: 
            next_state = state_stationary;
    endcase
    
end

always_comb begin : output_block
    request_served_o = ((request_down_i[current_floor] == 1'b1 || request_up_i[current_floor] == 1'b1) && pressed_buttons[requested_floor_i] == 1'b1) ? 1'b1 : 1'b0;
    case(current_state)
        state_stationary : begin
            direction_o = STATIONARY;
            floor_o = current_floor;
        end
        state_up : begin
            direction_o = GOING_UP;
            floor_o = current_floor;
        end
        state_down : begin
            direction_o = GOING_DOWN;
            floor_o = current_floor;
        end
        default : begin
            direction_o = STATIONARY;
            floor_o = current_floor;
        end
    endcase
end



endmodule