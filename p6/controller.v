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
        output reg [(`HILO_DEFAULT_SIGNAL_DIGIT - 1) : 0] HILOop,
        output reg HILOwen, //requires instant write-in without turning state into BUSY, instant HI/LO write only
        output reg [(`EXT_DEFAULT_SIGNAL_DIGIT - 1) : 0] EXTop,
        output reg [(`DMR_DEFAULT_SIGNAL_DIGIT - 1) : 0] DMRop,
        output reg [(`DME_DEFAULT_SIGNAL_DIGIT - 1) : 0] DMEop,
        
        //connection selectors
        output reg [(`IFU_valid_MAX_DIGITS - 1) : 0] IFUvalid,
        output reg [(`IFU_value_MAX_DIGITS - 1) : 0] IFUvalue,
        output reg [(`IFU_redirectValid_MAX_DIGITS - 1) : 0] IFUredirectValid,
        output reg [(`GRF_wa_MAX_DIGITS - 1) : 0] GRFwa,
        output reg [(`GRF_wd_MAX_DIGITS - 1) : 0] GRFwd,
        output reg [(`GRF_wen_MAX_DIGITS - 1) : 0] GRFwenPath,
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
            HILOop = 0;
            HILOwen = 0;
            EXTop = 0;
            DMRop = 0;
            DMEop = 0;
            IFUvalid = 0;
            IFUvalue = 0;
            IFUredirectValid = 0;
            GRFwa = 0;
            GRFwd = 0;
            GRFwenPath = 0;
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
            end
            else if(funct == `R_and) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_AND;
            end
            else if(funct == `R_or) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_OR;
            end
            else if(funct == `R_slt) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_SLT;
            end
            else if(funct == `R_sltu) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_GRFrd2;
                ALUop = `ALU_SLTU;
            end
            else if(funct == `R_mult) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                HILOop = `HILO_MULT;
                HILOwen = 1'b0; //not instant write
            end
            else if(funct == `R_multu) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                HILOop = `HILO_MULTU;
                HILOwen = 1'b0; //not instant write
            end
            else if(funct == `R_div) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                HILOop = `HILO_DIV;
                HILOwen = 1'b0; //not instant write
            end
            else if(funct == `R_divu) begin
                Tusers = 1;
                Tusert = 1;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                HILOop = `HILO_DIVU;
                HILOwen = 1'b0; //not instant write
            end
            else if(funct == `R_mfhi) begin
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwen = 1'b1;
                HILOop = `HILO_MFHI;
                HILOwen = 1'b0; //read from HI
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_HILOout;
            end
            else if(funct == `R_mflo) begin
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwen = 1'b1;
                HILOop = `HILO_MFLO;
                HILOwen = 1'b0; //read from LO
                GRFwa = `GRF_wa_IFUrd;
                GRFwd = `GRF_wd_HILOout;
            end
            else if(funct == `R_mthi) begin
                Tusers = 1;
                NPCop = `IFU_NPC_COMMON;
                HILOop = `HILO_MTHI;
                HILOwen = 1'b1; //instant write
            end
            else if(funct == `R_mtlo) begin
                Tusers = 1;
                NPCop = `IFU_NPC_COMMON;
                HILOop = `HILO_MTLO;
                HILOwen = 1'b1; //instant write
            end
            else if(funct == `R_jr) begin
                Tusers = 0;
                NPCop = `IFU_NPC_REG;
                IFUvalid = `IFU_valid_1;
                IFUvalue = `IFU_value_GRFrd1;
            end
        end
        else begin //i, j-type
            if(opcode == `OP_addi) begin
                Tusers = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                EXTop = `EXT_SIGN;
            end
            else if(opcode == `OP_andi) begin
                Tusers = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_AND;
                EXTop = `EXT_ZERO;
            end
            else if(opcode == `OP_ori) begin
                Tusers = 1;
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_OR;
                EXTop = `EXT_ZERO;
            end
            else if(opcode == `OP_lb) begin
                Tusers = 1;
                Tnew = 2;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_DMrd;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                EXTop = `EXT_SIGN;
                DMEop = `DME_SIGN_BYTE;
            end
            else if(opcode == `OP_lh) begin
                Tusers = 1;
                Tnew = 2;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_DMrd;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                EXTop = `EXT_SIGN;
                DMEop = `DME_SIGN_HALF;
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
                EXTop = `EXT_SIGN;
            end
            else if(opcode == `OP_sb) begin
                Tusers = 1;
                Tusert = 2;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                EXTop = `EXT_SIGN;
                DMRop = `DMR_BYTE;
            end
            else if(opcode == `OP_sh) begin
                Tusers = 1;
                Tusert = 2;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                EXTop = `EXT_SIGN;
                DMRop = `DMR_HALF;
            end
            else if(opcode == `OP_sw) begin
                Tusers = 1;
                Tusert = 2;
                Tnew = 0;
                NPCop = `IFU_NPC_COMMON;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_ADD;
                EXTop = `EXT_SIGN;
                DMRop = `DMR_WORD;
            end
            else if(opcode == `OP_beq) begin
                Tusers = 0;
                Tusert = 0;
                NPCop = `IFU_NPC_OFFSET;
                IFUvalid = `IFU_valid_CMPout;
                IFUvalue = `IFU_value_IFUimm;
                IFUredirectValid = `IFU_redirectValid_CMPout;
                CMPop = `CMP_EQ;
            end
            else if(opcode == `OP_bne) begin
                Tusers = 0;
                Tusert = 0;
                NPCop = `IFU_NPC_OFFSET;
                IFUvalid = `IFU_valid_CMPout;
                IFUvalue = `IFU_value_IFUimm;
                IFUredirectValid = `IFU_redirectValid_CMPout;
                CMPop = `CMP_NEQ;
            end
            else if(opcode == `OP_lui) begin
                Tnew = 1;
                NPCop = `IFU_NPC_COMMON;
                GRFwa = `GRF_wa_IFUrt;
                GRFwd = `GRF_wd_ALUout;
                GRFwen = 1'b1;
                ALUnum2 = `ALU_num2_EXTout;
                ALUop = `ALU_PASS2;
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
            end
            //ignore nop
        end
    end

endmodule
