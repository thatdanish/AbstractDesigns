`timescale 1ns/1ps
`default_nettype none

module vendingmachine_tb();

localparam CLOCKPERIOD = 100;
localparam FANTA = 2'b00;
localparam PEPSI = 2'b01;
localparam COLA = 2'b10;
localparam CAMPA = 2'b11;


logic clk_i, rst_i;
logic request, ready_o, start_pay_o, request_served_o, payment_ones, payment_fives, payment_tens;
logic[1:0] drink_o, drink_select;
logic[4:0] changes_o;

initial clk_i = 1'b0;
initial rst_i = 1'b0;

always #(CLOCKPERIOD/2) clk_i = ~clk_i;

initial begin
    #(20*CLOCKPERIOD + 3);
    rst_i = 1'b1;
end

initial begin
    request = 1'b0;
    drink_select = '0;
    payment_ones = 1'b0;
    payment_fives = 1'b0;
    payment_tens = 1'b0;

    wait(rst_i);
        wait(ready_o);
            #(CLOCKPERIOD);
            request = 1'b1;
            drink_select = FANTA;
            wait(start_pay_o);
                #(CLOCKPERIOD);
                payment_ones = 1'b1;
                payment_fives = 1'b0;
                payment_tens = 1'b0;
                #(CLOCKPERIOD);
                payment_ones = 1'b1;
                payment_fives = 1'b0;
                payment_tens = 1'b0;
                #(CLOCKPERIOD);
                payment_ones = 1'b0;
                payment_fives = 1'b0;
                payment_tens = 1'b1;
                #(CLOCKPERIOD);
                payment_ones = 1'b0;
                payment_fives = 1'b1;
                payment_tens = 1'b0;
                #(CLOCKPERIOD);
                payment_ones = 1'b0;
                payment_fives = 1'b0;
                payment_tens = 1'b0;
                wait(request_served_o);
                    request = 1'b0;
                    drink_select = '0;
                    payment_ones = 1'b0;
                    payment_fives = 1'b0;
                    payment_tens = 1'b0;

end

VendingMachneLogic vending_uut (
    .clk_i,
    .rst_i,
    .request_i(request),
    .drink_select_i(drink_select),
    .payment_ones_i(payment_ones),
    .payment_fives_i(payment_fives),
    .payment_tens_i(payment_tens),
    .ready_o,
    .start_pay_o,
    .drink_o,
    .request_served_o,
    .changes_o
);


initial begin
    // $dumpfile("vending.vcd");
    // $dumpvars(0, vendingmachine_tb);

    #(100*CLOCKPERIOD);
    $finish(0);
end
endmodule