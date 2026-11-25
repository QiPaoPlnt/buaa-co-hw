`timescale 1ns / 1ps

`include "defines.v"

module ifu(
        input clk,
        input reset,
        input [(`IFU_NPC_DEFAULT_SIGNAL_DIGIT - 1) : 0] NPCop,
        input NPCvalid,
        input [31:0] NPCvalue,
        output [31:0] pc0,
        output [31:0] pc4,
        output [31:0] command,
        output [5:0] opcode,
        output [4:0] rs,
        output [4:0] rt,
        output [4:0] rd,
        output [4:0] shamt,
        output [5:0] funct,
        output [15:0] imm,
        output [25:0] jump
    );

    wire [31:0] next_pc;
    wire [31:0] current_pc;
    wire [31:0] current_command;

    pc pc(
        .clk(clk),
        .reset(reset),
        .in(next_pc),
        .out(current_pc)
    );

    im im(
        .ra(current_pc),
        .rd(current_command)
    );

    npc npc(
        .current(current_pc),
        .op(NPCop),
        .valid(NPCvalid),
        .value(NPCvalue),
        .next(next_pc)
    );

    assign pc0 = current_pc;
    assign pc4 = current_pc + 4;
    assign command = current_command;
    assign opcode = current_command[31:26];
    assign rs = current_command[25:21];
    assign rt = current_command[20:16];
    assign rd = current_command[15:11];
    assign shamt = current_command[10:6];
    assign funct = current_command[5:0];
    assign imm = current_command[15:0];
    assign jump = current_command[25:0];


endmodule
