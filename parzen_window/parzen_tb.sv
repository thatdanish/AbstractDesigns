`timescale 1ns/1ps

module parzen_tb();

localparam CLOCKPERIOD = 100;
localparam SIZE_POW2 = 10;
localparam INTERNAL_FRAC = 16;
localparam OUTPUT_INT = 10;
localparam OUTPUT_FRAC = 16;


logic clk_i;
logic rst_i;
logic [SIZE_POW2-1:0] tri_wave;
logic [OUTPUT_INT-1:-OUTPUT_FRAC] window_output;

initial clk_i = 1'b0;
initial rst_i = 1'b0;

initial begin
    #(10*CLOCKPERIOD);
    rst_i = 1'b1;
end

always begin 
    #(CLOCKPERIOD/2);
    clk_i = ~clk_i;    
end


ParzenWindow_NP #(
    .WINDOW_SIZE_POW2(SIZE_POW2), 
    .INTERNAL_FRAC(INTERNAL_FRAC),
    .OUTPUT_INT(OUTPUT_INT),
    .OUTPUT_FRAC(OUTPUT_FRAC)
    ) parzen_dut (
        .clk_i,
        .rst_i,
        .tri_i(tri_wave),
        .win_o(window_output)
    );

triangle #(
    .SIZE_POW2(SIZE_POW2)
    ) triangle_dut (
    .clk_i,
    .rst_i,
    .val_o(tri_wave)
);

initial begin : vcd_block
    $dumplimit(1048576);  // 1 MB limit
    $dumpfile("parzen_dut.vcd");
    $dumpvars(0, parzen_tb);
end

initial begin : terminate_block
    #(CLOCKPERIOD*2000);
    $finish;
end
endmodule