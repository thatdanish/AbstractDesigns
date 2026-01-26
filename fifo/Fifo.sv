`default_nettype none
`timescale 1ns/1ps

module Fifo #(
    parameter LEN = 10,
    parameter SIZE = 32
) (
    input logic clk_i,
    input logic rst_i,
    input logic valid_i,
    input logic ready_i,
    input logic[SIZE-1:0] data_i,
    output logic[SIZE-1:0] data_o,
    output logic valid_o,
    output logic is_full_o
);

localparam PTR_BIT = 32;


// VARIABLE INDEXING FOR STRUCT TYPE ARRAY NOT SUPPORTED BY ICARUS (╥﹏╥)

// typedef struct packed {
//     bit data_valid;
//     logic[SIZE-1:0] data;
// } fifo_entry;

/////////////////////////////////////////////////////////////////////////////////////////
// fifo_entry [LEN-1:0] fifo;

logic [PTR_BIT-1:0] w_ptr, r_ptr;
logic [SIZE-1:0] fifo [LEN-1:0];
logic [LEN-1:0] data_stored;

assign is_full_o = & (data_stored);

always_ff @( posedge clk_i ) begin
    if (rst_i == 1'b0) begin
        w_ptr <= '0;
        r_ptr <= '0;
        // fifo <= '0;
        data_stored <= '0;
        data_o <= '0;
        valid_o <= 1'b0;
    end else begin
        valid_o <= 1'b0;
        if (valid_i == 1'b1) begin // data to be written
            w_ptr <= (w_ptr < LEN-1) ? w_ptr + 'd1 : '0;
            fifo[w_ptr] <= data_i;
            data_stored[w_ptr] <= 1'b1;
        end else if (ready_i == 1'b1) begin // data to be read
            r_ptr <= (r_ptr < LEN-1) ? r_ptr + 'd1 : '0;
            data_o <= fifo[r_ptr];
            data_stored <= 1'b0;
            valid_o <= 1'b1;
        end else begin
            r_ptr <= r_ptr;
            w_ptr <= w_ptr;
            // fifo <= fifo;
        end
    end
end


/////////////////////////////////////////////////////////////////////////////////////////
// ASSERTIONS --- NOT SUPPORTED BY ICARUS (╥﹏╥)
// property correct_read @(posedge clk_i); // when reading, r_ptr should store a valid data value.
//     ready_i |-> fifo[r_ptr].data_valid;
// endproperty
// assert property (correct_read) 
// else  $fatal("Incorrect READ");

// property correct_write @(posedge clk_i); // when writing, w_ptr should be empty.
//     valid_i |-> ! fifo[w_ptr].data_valid;
// endproperty
// assert property (correct_write) 
// else  $fatal("Incorrect WRITE");

// property overflow @(posedge clk_i); 
//     is_full_o |-> ! valid_i;
// endproperty
// assert property (overflow) 
// else  $fatal("OVERFLOW");

endmodule
