`timescale 1ns / 1ps

`include "defines.v"

module grf (
        input clk,
        input reset,
        input [4:0] ra1,
        input [4:0] ra2,
        input [4:0] wa,
        input [31:0] wd,
        input wen,
        //required for output
        input [31:0] pc,
        output [31:0] rd1,
        output [31:0] rd2
    );

    //CHANGE
    localparam READ_AMOUNT = 2, WRITE_AMOUNT = 1;

    //input interface
    wire [`F_RW(READ_AMOUNT) : 0] ra_all;
    wire [`F_RW(WRITE_AMOUNT) : 0] wa_all;
    wire [`F_DW(WRITE_AMOUNT) : 0] wd_all;
    wire [(WRITE_AMOUNT - 1) : 0] wen_all;

    //output interface
    wire [`F_DW(READ_AMOUNT) : 0] rd_all;

    //CHANGE
    assign ra_all = {ra2, ra1};
    assign wa_all = {wa};
    assign wd_all = {wd};
    assign wen_all = {wen && (wa != 5'd0)}; //does not allow to modify $0

    assign rd1 = rd_all[31:0];
    assign rd2 = rd_all[63:32];

    memory_internal #(
        .READ_AMOUNT(READ_AMOUNT),
        .WRITE_AMOUNT(WRITE_AMOUNT),
        .ADDR_WIDTH(`_RW),
        .REGISTER_SIZE(32)
    ) grf_core (
        .clk(clk),
        .reset(reset),
        .read_addr(ra_all),
        .write_addr(wa_all),
        .write_data(wd_all),
        .write_enable(wen_all),
        .read_data(rd_all)
    );

endmodule
