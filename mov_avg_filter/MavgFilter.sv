`default_nettype none

module MavgFilter #(
    parameter COEFF_BITS = 8,
    parameter INPUT_BITS = 16,
    parameter OUTPUT_BITS = 32
) (
    input logic clk_i,
    input logic rst_i,
    input logic signed [INPUT_BITS-1:0] original_data,
    output logic signed [OUTPUT_BITS-1:0] filtered_data
);

logic signed [COEFF_BITS-1:0] b [7:0];
logic signed [INPUT_BITS-1:0] sample [6:0];


generate
    genvar i;
    for (i = 0; i < 8; i++) begin
        assign  b[i] = 8'b00010000;
    end
endgenerate
    
always_ff @( posedge clk_i ) begin
    if (rst_i == 1'b0) begin
        sample[0] <= '0;
        sample[1] <= '0;
        sample[2] <= '0;
        sample[3] <= '0;
        sample[4] <= '0;
        sample[5] <= '0;
        sample[6] <= '0;
    end else begin
        sample[0] <= original_data;
        sample[1] <= sample[0];
        sample[2] <= sample[1];
        sample[3] <= sample[2];
        sample[4] <= sample[3];
        sample[5] <= sample[4];
        sample[6] <= sample[5];
    end
end

assign filtered_data = (b[0] * original_data) +
                       (b[1] * sample[0]) +
                       (b[2] * sample[1]) +
                       (b[3] * sample[2]) +
                       (b[4] * sample[3]) +
                       (b[5] * sample[4]) +
                       (b[6] * sample[5]) +
                       (b[7] * sample[6]) ;
endmodule