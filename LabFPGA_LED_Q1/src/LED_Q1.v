module led_q1 (
    input wire clk,
    output reg led
);

reg [22:0] counter = 23'd0;

initial begin
    led = 1'b1;
end

always @(posedge clk) begin
    if (counter == 25'd13_500_000) begin
        counter <= 23'd0;
        led <= ~led;
    end else begin
        counter <= counter + 23'd1;
    end
end

endmodule
