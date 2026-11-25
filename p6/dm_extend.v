`timescale 1ns / 1ps

`include "defines.v"

module dm_extend(
        input [31:0] addr,
        input [31:0] data,
        input [(`DME_DEFAULT_SIGNAL_DIGIT - 1) : 0] op,
        output reg [31:0] out
    );

    always @(*) begin
        case(op)
            `DME_NONE: begin
                out = data;
            end
            `DME_ZERO_BYTE: begin
                out = {{24{1'b0}}, data[(addr[1:0] * 8) +: 8]};
            end
            `DME_SIGN_BYTE: begin
                out = {{24{data[addr[1:0] * 8 + 7]}}, data[(addr[1:0] * 8) +: 8]};
            end
            `DME_ZERO_HALF: begin
                out = {{16{1'b0}}, data[(addr[1] * 16) +: 16]};
            end
            `DME_SIGN_HALF: begin
                out = {{16{data[addr[1] * 16 + 15]}}, data[(addr[1] * 16) +: 16]};
            end
            default: begin
                out = 0;
            end
        endcase
    end


endmodule
