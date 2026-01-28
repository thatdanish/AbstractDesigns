`timescale 1ns/1ps
`default_nettype none

module elevator_tb();

localparam CLOCKPERIOD = 100;
localparam MAXFLOORS = 10;
localparam MINFLOORS = 0;
localparam N_FLOORS = MAXFLOORS-MINFLOORS;

logic clk_i,rst_i;
logic[3:0] destination_floor, elevator_current_floor;
logic[1:0] elevator_direction;
logic ready;
logic[N_FLOORS-1:0] request_down, request_up;

initial clk_i = 1'b0;
initial rst_i = 1'b0;

always #(CLOCKPERIOD/2) clk_i = ~clk_i;

initial begin
    #(20*CLOCKPERIOD + 3);
    rst_i = 1'b1;
end

initial begin
    request_down = '0;
    request_up = '0;
    wait(rst_i);
        // REQ: 4 -> 8
        #(CLOCKPERIOD);
        request_up[4] = 1'b1;
        destination_floor = 4'd8;
        wait(ready);
            #(CLOCKPERIOD);
            request_up = '0;
       
        // REQ: 2 -> 9
        #(CLOCKPERIOD);
        request_up[2] = 1'b1;
        destination_floor = 4'd9;
        wait(ready);
            #(CLOCKPERIOD);
            request_up = '0;
        
        // REQ: 9 -> 2
        #(CLOCKPERIOD);
        request_down[9] = 1'b1;
        destination_floor = 4'd2;
        wait(ready);
            #(CLOCKPERIOD);
            request_down = '0;
        // Additional REQ : 6 -> 3
        #(CLOCKPERIOD);
        request_down[6] = 1'b1;
        destination_floor = 4'd3;
        wait(ready);
            #(CLOCKPERIOD);
            request_down = '0;

        // REQ: 2 -> 9
        #(CLOCKPERIOD);
        request_up[2] = 1'b1;
        destination_floor = 4'd9;
        wait(ready);
            #(CLOCKPERIOD);
            request_up = '0;
        // Additional REQ : 3 -> 6
        #(CLOCKPERIOD);
        request_up[3] = 1'b1;
        destination_floor = 4'd6;
        wait(ready);
            #(CLOCKPERIOD);
            request_up = '0;
end

ElevatorLogic #(
    .MAXFLOORS( MAXFLOORS   ),
    .MINFLOORS( MINFLOORS   )
) elevator_uut (
    .clk_i,
    .rst_i,
    .request_down_i     ( request_down              ),
    .request_up_i       ( request_up                ),
    .requested_floor_i  ( destination_floor         ),
    .floor_o            ( elevator_current_floor    ),
    .direction_o        ( elevator_direction        ),
    .request_served_o   ( ready                     )
);


initial begin
    $dumpfile("elevator.vcd");
    $dumpvars(0, elevator_tb);

    #(500*CLOCKPERIOD);
    $finish(0);
end

endmodule