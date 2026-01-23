`timescale 1ns/1ps

module fir_filter_mavg_tb();

localparam CLOCKPERIOD = 100;
localparam COEFF_BITS = 8;
localparam INPUT_BITS = 16;
localparam OUTPUT_BITS = 32;
localparam max_data = 1000;

logic clk_i, rst_i;
integer i,j;
logic signed [INPUT_BITS-1:0] data [max_data-1:0];
logic signed [INPUT_BITS-1:0] data_in;
logic signed [OUTPUT_BITS-1:0] data_out;


initial clk_i = 1'b0;
initial rst_i = 1'b0;

always begin
    #(CLOCKPERIOD/2) clk_i = ~clk_i;
end
initial begin
    #(CLOCKPERIOD*20);
    rst_i = 1'b1;
end

initial begin
    $readmemb("original.data", data);
    i = 0;
    forever begin
        @(posedge clk_i);
        if (rst_i) begin
            data_in = data[i];
            i = i+1;
        end
    end
end

initial begin
    integer file;
    file = $fopen("filtered.data");
    j = 0;
    forever begin
        @(posedge clk_i);
        if (rst_i) begin
            $fdisplay(file, "%b", data_out);
        end
    end
    $fclose(file);
end

MavgFilter #(
    .COEFF_BITS(COEFF_BITS),
    .INPUT_BITS(INPUT_BITS),
    .OUTPUT_BITS(OUTPUT_BITS)
    ) fir_filter (
        .clk_i,
        .rst_i,
        .original_data(data_in),
        .filtered_data(data_out)
    );

initial begin
    $dumpfile("fir.vcd");
    $dumpvars;
    #(CLOCKPERIOD*1021);
    $finish;
end

endmodule