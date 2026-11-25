`timescale 1ns / 1ps

`include "defines.v"

//RAM
module dm (
        input clk,
        input reset,
        input [31:0] ra,
        input [31:0] wa,
        input [31:0] wd,
        input wen,
        //required for output
        input [31:0] pc,
        output [31:0] rd
    );

    //CHANGE
    localparam READ_AMOUNT = 1, WRITE_AMOUNT = 1;
    localparam ADDR_WIDTH = 12, REGISTER_SIZE = 3072;

    wire [(ADDR_WIDTH - 1) : 0] calc_read_addr;
    assign calc_read_addr = ra >> 2;
    wire [(ADDR_WIDTH - 1) : 0] calc_write_addr;
    assign calc_write_addr = wa >> 2;

    //interfaces
    wire [`F_W(READ_AMOUNT, ADDR_WIDTH) : 0] read_addr;
    wire [`F_W(WRITE_AMOUNT, ADDR_WIDTH) : 0] write_addr;
    wire [`F_W(WRITE_AMOUNT, `_DW) : 0] write_data;
    wire [(WRITE_AMOUNT - 1) : 0] write_enable;
    wire [`F_W(READ_AMOUNT, `_DW) : 0] read_data;

    //CHANGE
    assign read_addr = {calc_read_addr};
    assign write_addr = {calc_write_addr};
    assign write_data = {wd};
    assign write_enable = {wen};

    assign rd = read_data[31:0];

    memory_internal #(
        .READ_AMOUNT(READ_AMOUNT),
        .WRITE_AMOUNT(WRITE_AMOUNT),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REGISTER_SIZE(REGISTER_SIZE)
    ) memory_core (
        .clk(clk),
        .reset(reset),
        .read_addr(read_addr),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_enable(write_enable),
        .read_data(read_data)
    );

    always @(posedge clk) begin
        if(!reset && wen) begin
            $display("%d@%h: *%h <= %h", $time, pc, wa, wd);
        end
    end

endmodule
