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