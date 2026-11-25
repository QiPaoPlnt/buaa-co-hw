`timescale 1ns / 1ps

`include "defines.v"

//ROM
module im (
        input [31:0] ra,
        output [31:0] rd
    );

    //CHANGE
    localparam READ_AMOUNT = 1, WRITE_AMOUNT = 1;
    localparam ADDR_WIDTH = 12, REGISTER_SIZE = 4096;

    wire [(ADDR_WIDTH - 1) : 0] calc_read_addr;
    assign calc_read_addr = (ra < 32'h00003000) ? 0 : ((ra - 32'h00003000) >> 2);

    //interfaces
    wire [`F_W(READ_AMOUNT, ADDR_WIDTH) : 0] read_addr;
    wire [`F_W(READ_AMOUNT, `_DW) : 0] read_data;

    //CHANGE
    assign read_addr = {calc_read_addr};

    assign rd = read_data[31:0];

    memory_internal #(
        .READ_AMOUNT(READ_AMOUNT),
        .WRITE_AMOUNT(WRITE_AMOUNT),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REGISTER_SIZE(REGISTER_SIZE),
        .ENABLE_INITIAL(1)
    ) memory_core (
        .clk(0),
        .reset(0),
        .read_addr(read_addr),
        .write_addr(0),
        .write_data(0),
        .write_enable(0),
        .read_data(read_data)
    );


endmodule
