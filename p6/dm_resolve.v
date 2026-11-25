`timescale 1ns / 1ps

`include "defines.v"

module dm_resolve(
        input [31:0] addr,
        //Note that data are always aligned to pos 0
        input [31:0] data,
        input [(`DMR_DEFAULT_SIGNAL_DIGIT - 1) : 0] op,
        output reg [3:0] outWen,
        output reg [31:0] outData
    );

    reg [1:0] temp_offset;
    reg [31:0] temp_data;

    always @(*) begin
        case(op)
            `DMR_OFF: begin
                outWen = 0;
                outData = 0;
            end
            `DMR_WORD: begin
                outWen = 4'b1111;
                outData = data;
            end
            `DMR_HALF: begin
                temp_offset = addr[1:0] & 2'b10;
                outWen = 4'b0011 << temp_offset;
                temp_data = {{16{1'b0}}, data[15:0]};
                temp_data = temp_data << (8 * temp_offset);
                outData = temp_data;
            end
            `DMR_BYTE: begin
                temp_offset = addr[1:0] & 2'b11;
                outWen = 4'b0001 << temp_offset;
                temp_data = {{24{1'b0}}, data[7:0]};
                temp_data = temp_data << (8 * temp_offset);
                outData = temp_data;
            end
            default: begin
                outWen = 0;
                outData = 0;
            end
        endcase
    end

endmodule
