module seg_counter (
    input wire clk,
    input wire rst_n,
    output reg [6:0] seg
);

localparam [24:0] HALF_SECOND_LAST = 25'd13_499_999;
localparam [3:0] STUDENT_LAST_DIGIT_PLUS_5 = 4'd6;

reg [24:0] clk_div = 25'd0;
reg [3:0] digit = 4'd0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_div <= 25'd0;
        digit <= 4'd0;
    end else if (clk_div == HALF_SECOND_LAST) begin
        clk_div <= 25'd0;
        if (digit == STUDENT_LAST_DIGIT_PLUS_5) begin
            digit <= 4'd0;
        end else begin
            digit <= digit + 4'd1;
        end
    end else begin
        clk_div <= clk_div + 25'd1;
    end
end

always @(*) begin
    case (digit)
        4'h0: seg = 7'b1111110;
        4'h1: seg = 7'b0110000;
        4'h2: seg = 7'b1101101;
        4'h3: seg = 7'b1111001;
        4'h4: seg = 7'b0110011;
        4'h5: seg = 7'b1011011;
        4'h6: seg = 7'b1011111;
        4'h7: seg = 7'b1110000;
        4'h8: seg = 7'b1111111;
        4'h9: seg = 7'b1111011;
        4'hA: seg = 7'b1110111;
        4'hB: seg = 7'b0011111;
        4'hC: seg = 7'b1001110;
        4'hD: seg = 7'b0111101;
        4'hE: seg = 7'b1001111;
        4'hF: seg = 7'b1000111;
        default: seg = 7'b0000000;
    endcase
end

endmodule
