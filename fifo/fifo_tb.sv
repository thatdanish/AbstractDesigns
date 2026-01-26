`default_nettype none
`timescale 1ns/1ps


module fifo_tb();

localparam CLOCKPERIOD = 100;
localparam SIZE = 32;
localparam LEN = 50;

logic clk_i, rst_i, valid_in, ready_in, valid_out, is_full_out;
logic [SIZE-1:0] data_write, data_read;

initial clk_i = 1'b0;
initial rst_i = 1'b0;

always #(CLOCKPERIOD/2) clk_i = ~clk_i;

initial begin
    #(20*CLOCKPERIOD+3);
    rst_i = 1'b1;
end


initial begin
    valid_in = 1'b0;
    ready_in = 1'b0;
    data_write = 'd0;

    wait (rst_i);
        #(CLOCKPERIOD);
        valid_in = 1'b1;
        data_write = 32'habcdefaa;
        #(CLOCKPERIOD);
        data_write = 32'hdeaddead;
        #(CLOCKPERIOD);
        data_write = 32'haaaaaaaa;
        #(CLOCKPERIOD);
        data_write = 32'hdddddddd;
        #(CLOCKPERIOD);
        valid_in = 1'b0;
        #(CLOCKPERIOD);
        ready_in = 1'b1;
        #(2*CLOCKPERIOD);
        ready_in = 1'b0;
end

Fifo #(
    .SIZE(SIZE),
    .LEN(LEN)
) fifo_uut (
    .clk_i,
    .rst_i,
    .valid_i(valid_in),
    .ready_i(ready_in),
    .data_i(data_write),
    .data_o(data_read),
    .valid_o(valid_out),
    .is_full_o(is_full_out)
);

initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, fifo_tb);
    
    #(500*CLOCKPERIOD);
    $finish(0);
end




endmodule