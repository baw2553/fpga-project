module led_q3 (
    input wire clk,
    output reg board_led,
    output wire ext_led
);

localparam [21:0] FOUR_HZ_HALF_PERIOD_LAST = 22'd3_374_999;

reg [21:0] counter = 22'd0;

assign ext_led = board_led;

initial begin
    board_led = 1'b1;
end

always @(posedge clk) begin
    if (counter == FOUR_HZ_HALF_PERIOD_LAST) begin
        counter <= 22'd0;
        board_led <= ~board_led;
    end else begin
        counter <= counter + 22'd1;
    end
end

endmodule
