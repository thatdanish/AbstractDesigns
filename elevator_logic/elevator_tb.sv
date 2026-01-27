`timescale 1ns/1ps
`default_nettype none

module elevator_tb();

localparam CLOCKPERIOD = 100;
localparam MAXFLOORS = 10;
localparam MINFLOORS = 0;

logic clk_i,rst_i;
logic[3:0] current_floor, destination_floor, elevator_current_floor;
logic[1:0] elevator_direction;
logic ready, request;

initial clk_i = 1'b0;
initial rst_i = 1'b0;

always #(CLOCKPERIOD/2) clk_i = ~clk_i;

initial begin
    #(20*CLOCKPERIOD + 3);
    rst_i = 1'b1;
end

initial begin
    wait(rst_i);
        #(2*CLOCKPERIOD);
        request = 1'b1;
        current_floor = 4'd4;
        destination_floor = 4'd8;
        wait(ready) request = 1'b0;
end

ElevatorLogic #(
    .MAXFLOORS(MAXFLOORS),
    .MINFLOORS(MINFLOORS)
) elevator_uut (
    .clk_i,
    .rst_i,
    .request_i(request),
    .requested_current_floor_i(current_floor),
    .requested_destination_floor_i(destination_floor),
    .floor_o(elevator_current_floor),
    .direction_o(elevator_direction),
    .request_served_o(ready)
);


initial begin
    $dumpfile("elevator.vcd");
    $dumpvars(0, elevator_tb);

    #(500*CLOCKPERIOD);
    $finish(0);
end

endmodule