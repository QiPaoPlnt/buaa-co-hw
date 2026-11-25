`timescale 1ns / 1ps

`include "defines.v"

module alu #(
        parameter SIGNAL_DIGIT = `ALU_DEFAULT_SIGNAL_DIGIT
    )(
        input [31:0] num1,
        input [31:0] num2,
        //CHANGE: if we have to add the 3rd number, just add it and fix corresponding operations, and that's enough
        //likely, if we have to add other outputs, do the same thing and it is enough as well
        input [(SIGNAL_DIGIT - 1) : 0] op,
        output reg [31:0] out
    );

    always @(*) begin
        case(op)
            `ALU_ADD: begin
                out = num1 + num2;
            end
            `ALU_SUB: begin
                out = num1 - num2;
            end
            `ALU_OR: begin
                out = num1 | num2;
            end
            default: begin
                out = 0;
            end
        endcase
    end

endmodule
