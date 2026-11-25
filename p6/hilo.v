`timescale 1ns / 1ps

`include "defines.v"

//Arithmetic Unit for HI & LO
//Usually for multiplication & division
module hilo #(
        parameter MULT_SLEEP = 5,
        parameter DIV_SLEEP = 10
    )(
        input clk,
        input reset,
        input [31:0] num1,
        input [31:0] num2,
        input [(`HILO_DEFAULT_SIGNAL_DIGIT - 1) : 0] op,
        input wen, //write in this tick, no need to get busy
        output start, //equals to busy, but instant, does not count instant operations
        output reg busy, //get busy, will write in at the end of busy state
        output reg [31:0] out
    );

    wire [63:0] sign_extended_num1 = {{32{num1[31]}}, num1}, sign_extended_num2 = {{32{num2[31]}}, num2},
                zero_extended_num1 = {{32{1'b0}}, num1}, zero_extended_num2 = {{32{1'b0}}, num2};

    reg [63:0] buffer;

    reg [31:0] calcTempHI, calcTempLO;

    reg [31:0] HI, LO;

    reg [3:0] timer;

    always @(posedge clk) begin
        if(reset) begin
            HI <= 0;
            LO <= 0;
            timer <= 0;
            busy <= 0;
        end
        else begin
            if(timer) begin
                timer <= timer - 1;
            end
            else begin
                if(wen || busy) begin
                    busy <= 0;
                    HI <= calcTempHI;
                    LO <= calcTempLO;
                end
                else begin
                    case(op) //enum for delayed times
                        `HILO_MULT, `HILO_MULTU: begin
                            busy <= 1'b1;
                            timer <= MULT_SLEEP - 1; //busy will turn to 0 AFTER timer turns to 0
                        end
                        `HILO_DIV, `HILO_DIVU: begin
                            busy <= 1'b1;
                            timer <= DIV_SLEEP - 1; //busy will turn to 0 AFTER timer turns to 0
                        end
                        default: begin //other instant operations
                            timer <= 0;
                        end
                    endcase
                end
            end
        end
    end

    assign start = (op == `HILO_MULT) || (op == `HILO_MULTU) || (op == `HILO_DIV) || (op == `HILO_DIVU);

    always @(*) begin
        out = 0;
        if(reset) begin
            out = 0;
            calcTempHI = 0;
            calcTempLO = 0;
            buffer = 0;
        end
        else begin
            case(op) //enum for arithmetic calculations
                `HILO_MULT: begin
                    buffer = ($signed(sign_extended_num1) * $signed(sign_extended_num2));
                    calcTempHI = buffer[63:32];
                    calcTempLO = buffer[31:0];
                end
                `HILO_MULTU: begin
                    buffer = (zero_extended_num1 * zero_extended_num2);
                    calcTempHI = buffer[63:32];
                    calcTempLO = buffer[31:0];
                end
                `HILO_DIV: begin
                    buffer = {{32{1'b0}}, ($signed(num1) % $signed(num2))};
                    calcTempHI = buffer[31:0];
                    buffer = {{32{1'b0}}, ($signed(num1) / $signed(num2))};
                    calcTempLO = buffer[31:0];
                end
                `HILO_DIVU: begin
                    buffer = {{32{1'b0}}, (num1 % num2)};
                    calcTempHI = buffer[31:0];
                    buffer = {{32{1'b0}}, (num1 / num2)};
                    calcTempLO = buffer[31:0];
                end
                `HILO_MFHI: begin
                    out = HI;
                end
                `HILO_MFLO: begin
                    out = LO;
                end
                `HILO_MTHI: begin
                    calcTempHI = num1;
                end
                `HILO_MTLO: begin
                    calcTempLO = num1;
                end
                default: begin
                    out = 0;
                end
            endcase
        end
    end

endmodule
