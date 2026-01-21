`default_nettype none

module triangle #(
    parameter SIZE_POW2 = 10,
    parameter MIN = 0
) (
    input logic clk_i,
    input logic rst_i,
    output logic [SIZE_POW2-1:0] val_o
);

localparam MAX = 2**(SIZE_POW2-1);
logic f_top, f_bottom, f_up, f_down;

always_ff @(posedge clk_i) begin : flag_toggle
    if (rst_i == 1'b0) begin
        f_top <= '0;
        f_bottom <= '0;
        f_up <= '0;
        f_down <= '0;
    end
    else begin
        f_top <= (val_o == MAX - 2) ? 1'b1 : 1'b0;
        f_bottom <= (val_o == MIN + 2) ? 1'b1 : 1'b0; // gives one unwanted pulse after rester, but not harmful.
       
        if (f_up == 1'b0 && f_top == 1'b0 && f_bottom == 1'b0 && f_down == 1'b0) begin // After reset, go up
            f_up <= 1'b1;
            f_down <= 1'b0;
        end else if (f_up == 1'b1 && f_top == 1'b1) begin // reached max, go down
            f_up <= 1'b0;
            f_down <= 1'b1;
        end else if (f_down == 1'b1 && f_bottom == 1'b1) begin // reached min go up
            f_up <= 1'b1;
            f_down <= 1'b0;
        end else begin
            f_up <= f_up;
            f_down <= f_down;
        end

    end
end

always_ff @(posedge clk_i) begin : counter_blk
    if (rst_i == 1'b0) begin
        val_o <= '0;
    end else begin
        if (f_up == 1'b1) begin
            val_o <= val_o + 'd1;
        end else if (f_down == 1'b1) begin
            val_o <= val_o - 'd1;
        end else begin
            val_o <= val_o;
        end
    end
end
    
endmodule