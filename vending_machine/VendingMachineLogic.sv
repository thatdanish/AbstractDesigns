`default_nettype none

module VendingMachneLogic(
    input logic clk_i,
    input logic rst_i,
    input logic request_i,
    input logic[1:0] drink_select_i,
    input logic payment_ones_i,
    input logic payment_fives_i,
    input logic payment_tens_i,
    output logic ready_o,
    output logic start_pay_o,
    output logic[1:0] drink_o,
    output logic request_served_o,
    output logic[4:0] changes_o
 );

localparam FANTA = 2'b00;
localparam PEPSI = 2'b01;
localparam COLA = 2'b10;
localparam CAMPA = 2'b11;

// logic[4:0] price_arr [logic[1:0]] = '{
//     FANTA : 5'd15, 
//     PEPSI : 5'd20,
//     COLA : 5'd25,
//     CAMPA : 5'd10,
// }; NOT SUPPORTED BY ICARUS

localparam FANTA_PRICE = 5'd15;
localparam PEPSI_PRICE = 5'd20;
localparam COLA_PRICE = 5'd25;
localparam CAMPA_PRICE = 5'd10; 

typedef enum bit[2:0] { s_ready, s_select, s_pay, s_change, s_dispense} state_t;
state_t current_state, next_state;

logic[4:0] payment_expected, payment_done;


always_ff @( posedge clk_i ) begin
    if (rst_i == 1'b0) begin
        current_state <= s_ready;
    end else begin
        current_state <= next_state;

        if (current_state == s_pay) begin
            unique case({payment_ones_i, payment_fives_i, payment_tens_i})
                3'b100 : payment_done <= payment_done + 5'd1;
                3'b010 : payment_done <= payment_done + 5'd5;
                3'b001 : payment_done <= payment_done + 5'd10;
            endcase
        end else payment_done <= 'd0;
    end
    
end

always_comb begin 
    case(current_state) 
    s_ready : begin
        if (request_i == 1'b1) next_state = s_select;
        else next_state = s_ready;
    end
    s_select : begin
        case (drink_select_i)
            FANTA : payment_expected = FANTA_PRICE;
            PEPSI : payment_expected = PEPSI_PRICE;
            COLA : payment_expected = COLA_PRICE;
            CAMPA : payment_expected = CAMPA_PRICE;
            default : payment_expected = '0;
        endcase

        next_state = s_pay;
    end
    s_pay : begin
        if (payment_done > payment_expected) next_state = s_change;
        else if (payment_done == payment_expected) next_state = s_dispense;
        else next_state = s_pay;
    end
    s_change : begin
        $display("Change returned : %d", payment_done-payment_expected);
        next_state = s_dispense;
    end
    s_dispense : begin
        if (drink_select_i == FANTA) $strobe("Drink dispensed : FANTA");
        else if (drink_select_i == PEPSI) $strobe("Drink dispensed : PEPSI");
        else if (drink_select_i == COLA) $strobe("Drink dispensed : COLA");
        else $strobe("Drink dispensed : CAMPA");
        next_state = s_ready;
    end
    default : next_state = s_ready;
    endcase

end

always_comb begin 
    case(current_state) 
    s_ready :  begin
        ready_o = 1'b1; 
        start_pay_o = 1'b0;
        changes_o = '0;
        drink_o = 'd0;
        request_served_o = 1'b0;
    end
    s_select : begin
        ready_o = 1'b0; 
        start_pay_o = 1'b0;
        changes_o = '0;
        drink_o = 'd0;
        request_served_o = 1'b0;
    end
    s_pay : begin
        ready_o = 1'b0; 
        start_pay_o = 1'b1;
        changes_o = '0;
        drink_o = 'd0;
        request_served_o = 1'b0;
    end
    s_change :  begin
        ready_o = 1'b0; 
        start_pay_o = 1'b0;
        changes_o = payment_done-payment_expected;
        drink_o = 'd0;
        request_served_o = 1'b0;
    end
    s_dispense : begin
        ready_o = 1'b0; 
        start_pay_o = 1'b0;
        changes_o = '0;
        drink_o = drink_select_i;
        request_served_o = 1'b1;
    end
    default : begin
        ready_o = 1'b0; 
        start_pay_o = 1'b0;
        changes_o = '0;
        drink_o = 'd0;
        request_served_o = 1'b0;
    end
endcase

end


endmodule