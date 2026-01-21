`default_nettype none

module ParzenWindow_NP #(
    parameter WINDOW_SIZE_POW2 = 10,
    parameter INTERNAL_FRAC = 16,
    parameter OUTPUT_INT = 10, 
    parameter OUTPUT_FRAC = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic[WINDOW_SIZE_POW2-1:0] tri_i,
    output logic[OUTPUT_INT-1:-OUTPUT_FRAC] win_o
);

localparam B_INT = WINDOW_SIZE_POW2;
localparam B2_INT = B_INT + B_INT;
localparam B3_INT = B2_INT + B_INT;
localparam B_SCALE_INT = B_INT + 3;

localparam B_FRAC = INTERNAL_FRAC;
localparam B2_FRAC = B_FRAC + B_FRAC;
localparam B3_FRAC = B2_FRAC + B_FRAC;
localparam B_SCALE_FRAC = B_FRAC;

logic[B_INT-1:-B_FRAC] abs_n;
logic[B_INT-1:-B_FRAC] b;
logic[B2_INT-1:-B2_FRAC] b2;
logic[B3_INT-1:-B3_FRAC] b3;

logic[B_SCALE_INT-1:-B_SCALE_FRAC] c6b1;
logic[B_SCALE_INT-1:-B_SCALE_FRAC] c6b2;
logic[B_SCALE_INT-1:-B_SCALE_FRAC] c6b3;
logic[B_SCALE_INT-1:-B_SCALE_FRAC] c2b3;

logic[B_INT-1:-B_FRAC] one_constant;
logic[B_INT-1:-B_FRAC] two_constant;

logic[B_INT-1:-B_FRAC] f1;
logic[B_INT-1:-B_FRAC] f2;

assign abs_n[B_INT-1:0] = tri_i;
assign abs_n[-1:-B_FRAC] = '0;

assign b = abs_n >> (WINDOW_SIZE_POW2-1);
assign b2 = b*b; 
assign b3 = b2*b; 

assign c6b1 = b*6;
assign c6b2 = b2[B_INT-1:-B_FRAC]*6;
assign c6b3 = b3[B_INT-1:-B_FRAC]*6;
assign c2b3 = b3[B_INT-1:-B_FRAC]*2;

assign one_constant[B_INT-1:0] = 1;
assign one_constant[-1:-B_FRAC] = '0;

assign two_constant[B_INT-1:0] = 2;
assign two_constant[-1:-B_FRAC] = '0;

assign f1 = one_constant - c6b2 + c6b3;
assign f2 = two_constant - c6b1 + c6b2 - c2b3;

always_comb begin 
    if (rst_i == 1'b0) begin
        win_o = '0;
    end else begin
        if (tri_i[WINDOW_SIZE_POW2-1:WINDOW_SIZE_POW2-2] > 0) begin
            win_o = f1;
        end else begin
            win_o = f2;
        end
    end
    
end

endmodule