module seg_id11 (
    input wire clk,
    input wire rst_n,
    output reg [6:0] seg,
    output reg digit_tens,
    output reg digit_ones
);

localparam [24:0] HALF_SECOND_LAST = 25'd13_499_999;
localparam [6:0] STUDENT_LAST_TWO = 7'd11;
localparam [6:0] ADJUST_VALUE = 7'd16;
localparam [6:0] COUNT_LIMIT = (STUDENT_LAST_TWO < ADJUST_VALUE)
    ? STUDENT_LAST_TWO + ADJUST_VALUE
    : STUDENT_LAST_TWO;
localparam [3:0] LIMIT_TENS = COUNT_LIMIT / 7'd10;
localparam [3:0] LIMIT_ONES = COUNT_LIMIT % 7'd10;
localparam [13:0] SCAN_HALF_LAST = 14'd13_499;
localparam [5:0] BLANK_LAST = 6'd26;

reg [24:0] clk_div = 25'd0;
reg [3:0] tens = 4'd0;
reg [3:0] ones = 4'd0;
reg [13:0] scan_div = 14'd0;
reg [5:0] blank_div = 6'd0;
reg scan_tens = 1'b0;
reg blanking = 1'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_div <= 25'd0;
        tens <= 4'd0;
        ones <= 4'd0;
    end else if (clk_div == HALF_SECOND_LAST) begin
        clk_div <= 25'd0;
        if ((tens == LIMIT_TENS) && (ones == LIMIT_ONES)) begin
            tens <= 4'd0;
            ones <= 4'd0;
        end else if (ones == 4'd9) begin
            tens <= tens + 4'd1;
            ones <= 4'd0;
        end else begin
            ones <= ones + 4'd1;
        end
    end else begin
        clk_div <= clk_div + 25'd1;
    end
end

// Alternate the two common-cathode switches at about 1 kHz per digit.
// A short all-off interval prevents ghosting while the segment pattern changes.
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scan_div <= 14'd0;
        blank_div <= 6'd0;
        scan_tens <= 1'b0;
        blanking <= 1'b0;
    end else if (blanking) begin
        if (blank_div == BLANK_LAST) begin
            blank_div <= 6'd0;
            blanking <= 1'b0;
        end else begin
            blank_div <= blank_div + 6'd1;
        end
    end else if (scan_div == SCAN_HALF_LAST) begin
        scan_div <= 14'd0;
        blank_div <= 6'd0;
        scan_tens <= ~scan_tens;
        blanking <= 1'b1;
    end else begin
        scan_div <= scan_div + 14'd1;
    end
end

// Active-high common-cathode displays, seg[6:0] = {a,b,c,d,e,f,g}.
function [6:0] decode_digit;
    input [3:0] digit;
    begin
        case (digit)
            4'd0: decode_digit = 7'b1111110;
            4'd1: decode_digit = 7'b0110000;
            4'd2: decode_digit = 7'b1101101;
            4'd3: decode_digit = 7'b1111001;
            4'd4: decode_digit = 7'b0110011;
            4'd5: decode_digit = 7'b1011011;
            4'd6: decode_digit = 7'b1011111;
            4'd7: decode_digit = 7'b1110000;
            4'd8: decode_digit = 7'b1111111;
            4'd9: decode_digit = 7'b1111011;
            default: decode_digit = 7'b0000000;
        endcase
    end
endfunction

always @(*) begin
    seg = 7'b0000000;
    digit_tens = 1'b0;
    digit_ones = 1'b0;

    if (scan_tens) begin
        if (tens != 4'd0) begin
            seg = decode_digit(tens);
            if (!blanking)
                digit_tens = 1'b1;
        end
    end else begin
        seg = decode_digit(ones);
        if (!blanking)
            digit_ones = 1'b1;
    end
end

endmodule
