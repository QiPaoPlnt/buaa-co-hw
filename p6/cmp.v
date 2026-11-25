`timescale 1ns / 1ps

`include "defines.v"

//A calculation module at stage D
//for early branch / pre-ALU calculation
module cmp #(
        parameter SIGNAL_DIGIT = `CMP_DEFAULT_SIGNAL_DIGIT
    )(
        input [31:0] num1,
        input [31:0] num2,
        input [(SIGNAL_DIGIT - 1) : 0] op,
        output reg out
    );

    always @(*) begin
        case(op)
            `CMP_EQ: begin
                out = (num1 == num2);
            end
            `CMP_NEQ: begin
                out = (num1 != num2);
            end
            default: begin
                out = 0;
            end
        endcase
    end

endmodule
