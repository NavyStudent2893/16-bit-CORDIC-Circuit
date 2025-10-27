\TLV_version 1d: tl-x.org
\SV
/* verilator lint_off UNUSED*/  /* verilator lint_off DECLFILENAME*/  /* verilator lint_off BLKSEQ*/  /* verilator lint_off WIDTH*/  /* verilator lint_off SELRANGE*/  /* verilator lint_off PINCONNECTEMPTY*/  /* verilator lint_off DEFPARAM*/  /* verilator lint_off IMPLICIT*/  /* verilator lint_off COMBDLY*/  /* verilator lint_off SYNCASYNCNET*/  /* verilator lint_off UNOPTFLAT */  /* verilator lint_off UNSIGNED*/  /* verilator lint_off CASEINCOMPLETE*/  /* verilator lint_off UNDRIVEN*/  /* verilator lint_off VARHIDDEN*/  /* verilator lint_off CASEX*/  /* verilator lint_off CASEOVERLAP*/  /* verilator lint_off PINMISSING*/  /* verilator lint_off LATCH*/  /* verilator lint_off BLKANDNBLK*/  /* verilator lint_off MULTIDRIVEN*/  /* verilator lint_off NULLPORT*/  /* verilator lint_off EOFNEWLINE*/  /* verilator lint_off WIDTHCONCAT*/  /* verilator lint_off ASSIGNDLY*/  /* verilator lint_off MODDUP*/  /* verilator lint_off STMTDLY*/  /* verilator lint_off LITENDIAN*/  /* verilator lint_off INITIALDLY*/

//Your Verilog/System Verilog Code Starts Here:
`timescale 1ns / 1ps

// LUT Module (Dependency)
// FIX 3: Input port must be 5 bits to match the corrected counter
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



// CORDIC Design Module 
module cordic
#(parameter WIDTH = 16, parameter FRACTION_BITS = 13, parameter scaling_factor = 4974)
(
    input  wire clk,
    input  wire reset,
    input  wire signed [WIDTH-1:0] angle,    
    input  wire start,                        // signal to start rotation
    output reg  signed [WIDTH-1:0] cos_out,   // final x
    output reg  signed [WIDTH-1:0] sin_out,   // final y
    output reg  done
);
    // State encoding (3 states hence 2 bit enocding)
    parameter IDLE = 2'b00;
    parameter CALC = 2'b01;
    parameter DONE = 2'b10;
    
    // FSM state registers
    reg [1:0] current_state;
    reg [1:0] next_state;

    // Internal registers for calculaions
    reg signed [WIDTH-1:0] x_reg;
    reg signed [WIDTH-1:0] y_reg;
    reg signed [WIDTH-1:0] angle_reg; // Internal copy of the angle (As input port cannot be reg)

    // FIX 3: iter_count must be 5 bits to count to 16
    reg [4:0] iter_count;

    wire signed [15:0] current_angle_constant;
    
    // Module instantiation for the Angle Look-Up Table (Part of CORDIC algorithm)
    angle_lut lut1 (iter_count, current_angle_constant);

    // FSM BLOCK 1: State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // FSM BLOCK 2: Next-State Logic
    always @(*) begin
        next_state = current_state;
        case(current_state)
            IDLE: begin
                if (start) begin
                    next_state = CALC;
                end
            end
            CALC: begin
                // FIX 3: FSM goes to "DONE" state after 16 iterations are complete
                if (iter_count == WIDTH) begin
                    next_state = DONE;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end

    // FSM BLOCK 3: Datapath and Output Logic 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_reg      <= 0;
            y_reg      <= 0;
            angle_reg  <= 0;
            iter_count <= 0;
            cos_out    <= 0;
            sin_out    <= 0;
            done       <= 1'b0;
        end else begin
            case(current_state)
                IDLE: begin
                    done <= 1'b0; // De-assert done signal
                    if (start) begin
                        // Capture all inputs on start
                        angle_reg  <= angle;
                        x_reg      <= scaling_factor; // Load initial X
                        y_reg      <= 0;             // Load initial Y
                        iter_count <= 0;
                    end
                end
                
                CALC: begin
                    if (angle_reg >= 0) begin
                        angle_reg <= angle_reg - current_angle_constant;
                        x_reg     <= x_reg - (y_reg >>> iter_count); 
                        y_reg     <= y_reg + (x_reg >>> iter_count);
                    end else begin
                        angle_reg <= angle_reg + current_angle_constant;
                        x_reg     <= x_reg + (y_reg >>> iter_count); 
                        y_reg     <= y_reg - (x_reg >>> iter_count);
                    end

                    // Update counter for the next iteration
                    iter_count <= iter_count + 1;
                end

                DONE: begin
                    cos_out <= x_reg;
                    sin_out <= y_reg;
                    done    <= 1'b1;
                end
            endcase
        end
    end
endmodule

//Top Module Code Starts here:
module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);
    // Define WIDTH parameter used in this module
    localparam WIDTH = 16;
    
    logic signed [WIDTH-1:0] angle;
    logic                    start;
    logic signed [WIDTH-1:0] cos_out;
    logic signed [WIDTH-1:0] sin_out;
    logic                    done;

    assign angle = 16'sd5461; // For 30 degrees: round((30/180)*32768)
    
    assign start = (cyc_cnt == 10);
    
    cordic #(.WIDTH(WIDTH)) cordic_inst (
        .clk(clk), 
        .reset(reset), 
        .angle(angle), 
        .start(start), 
        .cos_out(cos_out), 
        .sin_out(sin_out), 
        .done(done)
    );
    
\TLV
//Add \TLV here if desired                                      
\SV
endmodule