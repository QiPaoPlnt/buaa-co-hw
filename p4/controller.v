`timescale 1ns / 1ps

`include "defines.v"

module controller(
        input [5:0] opcode,
        input [5:0] funct,
        //operation codes
        output reg [(`IFU_NPC_DEFAULT_SIGNAL_DIGIT - 1) : 0] NPCop,
        output reg GRFwen, //CHANGE: for multiple reg inputs
        output reg [(`ALU_DEFAULT_SIGNAL_DIGIT - 1) : 0] ALUop,
        output reg DMwen, //CHANGE: for multiple RAM inputs
        output reg [(`EXT_DEFAULT_SIGNAL_DIGIT - 1) : 0] EXTop,
        
        //connection selectors
        output reg [(`IFU_valid_MAX_DIGITS - 1) : 0] IFUvalid,
        output reg [(`IFU_value_MAX_DIGITS - 1) : 0] IFUvalue,
        output reg [(`GRF_wa_MAX_DIGITS - 1) : 0] GRFwa,
        output reg [(`GRF_wd_MAX_DIGITS - 1) : 0] GRFwd,
        output reg [(`ALU_num2_MAX_DIGITS - 1) : 0] ALUnum2
    );

    task resetValue;
        begin
            NPCop = 0;
            GRFwen = 0;
            ALUop = 0;
            DMwen = 0;
            EXTop = 0;
            IFUvalid = 0;
            IFUvalue = 0;
            GRFwa = 0;
            GRFwd = 0;
            ALUnum2 = 0;
        end
    endtask

    always @(*) begin
        resetValue;
        if(opcode == `OP_RType) begin //r-type
            if(funct == `R_add) begin
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_ADD;
                DMwen = 1'b0;
            end
            else if(funct == `R_sub) begin
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_SUB;
                DMwen = 1'b0;
            end
            else if(funct == `R_jr) begin
                NPCop = `IFU_NPC_REG;
                IFUvalid = `IFU_valid_1;
                IFUvalue = `IFU_value_ALUout;
                GRFwen = 1'b0;
                ALUop = `ALU_PASS1;
                DMwen = 1'b0;
            end
        end
        else begin //i, j-type
            if(opcode == `OP_ori) begin
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_OR;
                DMwen = 1'b0;
                EXTop = `EXT_ZERO;
            end
            else if(opcode == `OP_lw) begin
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_DMrd;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                DMwen = 1'b0;
                EXTop = `EXT_SIGN;
            end
            else if(opcode == `OP_sw) begin
                NPCop = `IFU_NPC_COMMON;
                GRFwen = 1'b0;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                DMwen = 1'b1;
                EXTop = `EXT_SIGN;
            end
            else if(opcode == `OP_beq) begin
                NPCop = `IFU_NPC_OFFSET;
                IFUvalid = `IFU_valid_ALUout;
                IFUvalue = `IFU_value_IFUimm;
                GRFwen = 1'b0;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_EQ;
                DMwen = 1'b0;
            end
            else if(opcode == `OP_lui) begin
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_OR;
                DMwen = 1'b0;
                EXTop = `EXT_HIGH;
            end
            else if(opcode == `OP_jal) begin
                NPCop = `IFU_NPC_JUMP;
                IFUvalid = `IFU_valid_1;
                IFUvalue = `IFU_value_IFUjump;
                GRFwa = `GRF_wa_31;
                GRFwd = `GRF_wd_PC4;
                GRFwen = 1'b1;
                DMwen = 1'b0;
            end
            //ignore nop
        end
    end

endmodule
