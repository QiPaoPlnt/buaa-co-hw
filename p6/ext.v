`timescale 1ns / 1ps

`include "defines.v"

module ext #(
        parameter SIGNAL_DIGIT = `EXT_DEFAULT_SIGNAL_DIGIT,
        parameter ORIGINAL_DIGIT = 16
    )(
        input [(ORIGINAL_DIGIT - 1) : 0] imm,
        input [(SIGNAL_DIGIT - 1) : 0] op,
        output reg [31:0] out
    );

    always @(*) begin
        case(op)
            `EXT_ZERO: begin
                out = {{(32 - ORIGINAL_DIGIT){1'b0}}, imm};
            end
            `EXT_SIGN: begin
                out = {{(32 - ORIGINAL_DIGIT){imm[ORIGINAL_DIGIT - 1]}}, imm};
            end
            `EXT_HIGH: begin
                out = {imm, {(32 - ORIGINAL_DIGIT){1'b0}}};
            end
            default: begin
                out = {{(32 - ORIGINAL_DIGIT){1'b0}}, imm};
            end
        endcase
    end


endmodule
