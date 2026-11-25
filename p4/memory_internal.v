`timescale 1ns / 1ps

`include "defines.v"

//overall memory abstract
module memory_internal #(
        parameter READ_AMOUNT = 2,
        parameter WRITE_AMOUNT = 1,
        parameter ADDR_WIDTH = 5,
        parameter REGISTER_SIZE = 32,
        parameter ENABLE_INITIAL = 0
    )(
        input clk,
        input reset,
        input [`F_W(READ_AMOUNT, ADDR_WIDTH) : 0] read_addr,
        input [`F_W(WRITE_AMOUNT, ADDR_WIDTH) : 0] write_addr,
        input [`F_DW(WRITE_AMOUNT) : 0] write_data,
        input [(WRITE_AMOUNT - 1) : 0] write_enable,
        output [`F_DW(READ_AMOUNT) : 0] read_data
    );

    reg [31:0] registers[0 : (REGISTER_SIZE - 1)];

    genvar gi;
    generate
        for (gi = 0; gi < READ_AMOUNT; gi = gi + 1) begin : read_assign
            //this also showcases the grammar, they are the same!
            //but we have to notice the reversed index...
            assign read_data[((gi + 1) * `_DW - 1) : (gi * `_DW)] = registers[ read_addr[(gi * ADDR_WIDTH) +: ADDR_WIDTH] ];
        end
    endgenerate


    integer i;
    always @(posedge clk) begin
        if(reset) begin
            for (i = 0; i < REGISTER_SIZE; i = i + 1) begin
                registers[i] <= 0;
            end
        end
        else begin
            for (i = 0; i < WRITE_AMOUNT; i = i + 1) begin
                if(write_enable[i]) begin
                    registers[ write_addr[(i * ADDR_WIDTH) +: ADDR_WIDTH] ] <= write_data[(i * `_DW) +: `_DW];
                end
            end
        end
    end

    initial begin
        if(ENABLE_INITIAL) begin
            $readmemh("code.txt", registers);
        end
    end

endmodule
