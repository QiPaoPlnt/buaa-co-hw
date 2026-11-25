`timescale 1ns / 1ps

module pc(
        input clk,
        input reset,
        input stall,
        input [31:0] in,
        output reg [31:0] out
    );

    always @(posedge clk) begin
        if(reset) begin
            out <= 32'h00003000;
        end
        else begin
            if(!stall) begin
                out <= in;
            end
        end
    end

endmodule
