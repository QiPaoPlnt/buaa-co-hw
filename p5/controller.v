`timescale 1ns / 1ps

`include "defines.v"

module controller(
        input [5:0] opcode,
        input [5:0] funct,
        //time expectations
        output reg [3:0] Tusers,
        output reg [3:0] Tusert,
        output reg [3:0] Tnew,
        output reg GRFwaUnknown_initial,
        output reg GRFwenUnknown_initial,

        //operation codes
        output reg [(`IFU_NPC_DEFAULT_SIGNAL_DIGIT - 1) : 0] NPCop,
        output reg GRFwen, //CHANGE: for multiple reg inputs
        output reg [(`CMP_DEFAULT_SIGNAL_DIGIT - 1) : 0] CMPop,
        output reg [(`ALU_DEFAULT_SIGNAL_DIGIT - 1) : 0] ALUop,
        output reg DMwen, //CHANGE: for multiple RAM inputs
        output reg [(`EXT_DEFAULT_SIGNAL_DIGIT - 1) : 0] EXTop,
        
        //connection selectors
        output reg [(`IFU_valid_MAX_DIGITS - 1) : 0] IFUvalid,
        output reg [(`IFU_value_MAX_DIGITS - 1) : 0] IFUvalue,
        output reg [(`IFU_redirectValid_MAX_DIGITS - 1) : 0] IFUredirectValid,
        output reg [(`GRF_wa_MAX_DIGITS - 1) : 0] GRFwa,
        output reg [(`GRF_wd_MAX_DIGITS - 1) : 0] GRFwd,
        output reg [(`ALU_num2_MAX_DIGITS - 1) : 0] ALUnum2
    );

    task resetValue;
        begin
            Tusers = `Tuse_MAX;
            Tusert = `Tuse_MAX;
            Tnew = 4'd0;
            GRFwaUnknown_initial = 0;
            GRFwenUnknown_initial = 0;
            NPCop = 0;
            GRFwen = 0;
            CMPop = 0;
            ALUop = 0;
            DMwen = 0;
            EXTop = 0;
            IFUvalid = 0;
            IFUvalue = 0;
            IFUredirectValid = 0;
            GRFwa = 0;
            GRFwd = 0;
            ALUnum2 = 0;
        end
    endtask

    always @(*) begin
        resetValue;
        if(opcode == `OP_RType) begin //r-type
            if(funct == `R_add) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_ADD;
                DMwen = 1'b0;
            end
            else if(funct == `R_sub) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_SUB;
                DMwen = 1'b0;
            end
            else if(funct == `R_jr) begin
                Tusers = 0;
                NPCop = `IFU_NPC_REG;
                IFUvalid = `IFU_valid_1;
                IFUvalue = `IFU_value_GRFrd1;
                GRFwen = 1'b0;
                DMwen = 1'b0;
            end
        end
        else begin //i, j-type
            if(opcode == `OP_ori) begin
                Tusers = 1;
                Tnew = 1;
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
                Tusers = 1;
                Tnew = 2;
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
                Tusers = 1;
                Tusert = 2;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                GRFwen = 1'b0;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                DMwen = 1'b1;
                EXTop = `EXT_SIGN;
            end
            else if(opcode == `OP_beq) begin
                Tusers = 0;
                Tusert = 0;
                NPCop = `IFU_NPC_OFFSET;
                IFUvalid = `IFU_valid_CMPout;
                IFUvalue = `IFU_value_IFUimm;
                IFUredirectValid = `IFU_redirectValid_CMPout;
                GRFwen = 1'b0;
                DMwen = 1'b0;
                CMPop = `CMP_EQ;
            end
            else if(opcode == `OP_lui) begin
                Tusers = 1;
                Tnew = 1;
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
                Tnew = 0;
                NPCop = `IFU_NPC_JUMP;
                IFUvalid = `IFU_valid_1;
                IFUvalue = `IFU_value_IFUjump;
                GRFwa = `GRF_wa_31;
                GRFwd = `GRF_wd_PC8;
                GRFwen = 1'b1;
                DMwen = 1'b0;
            end
            //ignore nop
        end
    end

endmodule
