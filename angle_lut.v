module angle_lut (
    input  wire [4:0] iter_count,
    output reg  signed [15:0] angle_constant
);
    always @(*) begin
        // These values use a 2^15 scaling for the angle
        case (iter_count)
            5'd0:  angle_constant = 16'sd8192; // atan(2^0)   = 45.000°
            5'd1:  angle_constant = 16'sd4836; // atan(2^-1)  = 26.565°
            5'd2:  angle_constant = 16'sd2569; // atan(2^-2)  = 14.036°
            5'd3:  angle_constant = 16'sd1312; // atan(2^-3)  = 7.125°
            5'd4:  angle_constant = 16'sd658;  // atan(2^-4)  = 3.576°
            5'd5:  angle_constant = 16'sd329;  // atan(2^-5)  = 1.789°
            5'd6:  angle_constant = 16'sd164;  // atan(2^-6)  = 0.895°
            5'd7:  angle_constant = 16'sd82;   // atan(2^-7)  = 0.447°
            5'd8:  angle_constant = 16'sd41;   // atan(2^-8)  = 0.224°
            5'd9:  angle_constant = 16'sd20;   // atan(2^-9)  = 0.112°
            5'd10: angle_constant = 16'sd10;   // atan(2^-10) = 0.056°
            5'd11: angle_constant = 16'sd5;    // atan(2^-11) = 0.028°
            5'd12: angle_constant = 16'sd2;    // atan(2^-12) = 0.014°
            5'd13: angle_constant = 16'sd1;
            5'd14: angle_constant = 16'sd0;
            5'd15: angle_constant = 16'sd0;
            default: angle_constant = 16'sd0;
        endcase
    end
endmodule