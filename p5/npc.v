`timescale 1ns / 1ps

`include "defines.v"

module npc #(
        parameter SIGNAL_DIGIT = `IFU_NPC_DEFAULT_SIGNAL_DIGIT
    )(
        input [31:0] current,
        input [(SIGNAL_DIGIT - 1) : 0] op,
        input valid, //apply to some kinds of operations that requires validation
        input [31:0] value, //could be 16-offset, 26-jump, 32-reg
        output reg [31:0] next
    );

    //CHANGE
    //the following shows a way to add a new kind of formatting 
    //offset
    wire [17:0] offset_catch = {{value[15:0]}, {2{1'b0}}};
    wire [31:0] offset_extended;
    ext #(
        .ORIGINAL_DIGIT(18)
    ) ext_offset (
        .imm(offset_catch),
        .op(`EXT_SIGN),
        .out(offset_extended)
    );

    //jump
    wire [31:0] jump_extended = {{current[31:28]}, {value[25:0]}, {2{1'b0}}};

    always @(*) begin
        case(op)
            `IFU_NPC_COMMON: begin
                next = current + 4;
            end
            `IFU_NPC_OFFSET: begin
                if(valid) begin
                    next = current + 4 + offset_extended;
                end
                else begin
                    next = current + 4;
                end
            end
            `IFU_NPC_JUMP: begin
                next = jump_extended;
            end
            `IFU_NPC_REG: begin
                next = value;
            end
            default: begin
                next = current + 4;
            end
        endcase
    end

endmodule
