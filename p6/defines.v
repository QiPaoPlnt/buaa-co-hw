`ifndef _CYBERPUNK
`define _CYBERPUNK 2077

`ifndef _BUILD_ID
`define _BUILD_ID 32'h0183_2180
`endif

//DON'T FORGET TO USE '`' BEFORE MACRO!

//=====general parameters=====
`define DATA_WIDTH 32
`define _DW `DATA_WIDTH

`define REG_WIDTH 5
`define _RW `REG_WIDTH

`define FUNC_WIDTH(x, width) (((x) * (width)) - 1)
`define F_W(x, width) `FUNC_WIDTH((x), (width))

`define FUNC_DATA_WIDTH(x) `FUNC_WIDTH((x), `DATA_WIDTH)
`define F_DW(x) `FUNC_DATA_WIDTH(x)

`define FUNC_REG_WIDTH(x) `FUNC_WIDTH((x), `REG_WIDTH)
`define F_RW(x) `FUNC_REG_WIDTH(x)

`define F_MIN(x, y) ((x) < (y) ? (x) : (y))
`define F_MAX(x, y) ((x) > (y) ? (x) : (y))

`define F_POSDEC(x) (((x) == 0) ? 0 : ((x) - 1))

//=====pipe signals=====
`define PIPE_STAGE_F 0
`define PIPE_STAGE_D 1
`define PIPE_STAGE_E 2
`define PIPE_STAGE_M 3
`define PIPE_STAGE_W 4

//=====ifu signals=====

//ifu.npc
`define IFU_NPC_COMMON 0
`define IFU_NPC_OFFSET 1
`define IFU_NPC_JUMP 2
`define IFU_NPC_REG 3

`define IFU_NPC_DEFAULT_SIGNAL_DIGIT 4

//=====alu signals=====
`define ALU_ADD 1
`define ALU_SUB 2
`define ALU_AND 3
`define ALU_OR 4
`define ALU_SLT 5
`define ALU_SLTU 6
`define ALU_PASS1 7
`define ALU_PASS2 8

`define ALU_DEFAULT_SIGNAL_DIGIT 4

//=====ext signals=====
`define EXT_ZERO 0
`define EXT_SIGN 1
`define EXT_HIGH 2

`define EXT_DEFAULT_SIGNAL_DIGIT 4

//=====cmp signals=====
`define CMP_EQ 1
`define CMP_NEQ 2

`define CMP_DEFAULT_SIGNAL_DIGIT 4

//=====hilo signals=====
`define HILO_NONE 0
`define HILO_MULT 1
`define HILO_MULTU 2
`define HILO_DIV 3
`define HILO_DIVU 4
`define HILO_MFHI 5
`define HILO_MFLO 6
`define HILO_MTHI 7
`define HILO_MTLO 8

`define HILO_DEFAULT_SIGNAL_DIGIT 4

//=====dmr signals=====
`define DMR_OFF 0
`define DMR_WORD 1
`define DMR_HALF 2
`define DMR_BYTE 3

`define DMR_DEFAULT_SIGNAL_DIGIT 4

//=====dme signals=====
`define DME_NONE 0
`define DME_ZERO_BYTE 1
`define DME_SIGN_BYTE 2
`define DME_ZERO_HALF 3
`define DME_SIGN_HALF 4

`define DME_DEFAULT_SIGNAL_DIGIT 4

//=====connection signals=====

//ifu.valid
`define IFU_valid_CMPout 0
`define IFU_valid_1 1

`define IFU_valid_MAX_DIGITS 4

//ifu.value
`define IFU_value_IFUimm 0
`define IFU_value_IFUjump 1
`define IFU_value_GRFrd1 2

`define IFU_value_MAX_DIGITS 4

//ifu.redirectValid
`define IFU_redirectValid_0 0
`define IFU_redirectValid_CMPout 1

`define IFU_redirectValid_MAX_DIGITS 4

//grf.wen
`define GRF_wen_CON 0

`define GRF_wen_MAX_DIGITS 4

//grf.wa
`define GRF_wa_IFUrd 0
`define GRF_wa_IFUrt 1
`define GRF_wa_31 2

`define GRF_wa_MAX_DIGITS 4

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!
//! IT IS POSSIBLE TO MODIFY GRF.WD, HOWEVER,
//! YOU MUST MODIFY FORWARDING PROCESS AS WELL, (selectPort() & always(...))
//! AS THEY SHOULD USE YOUR DATA SOURCE TO SEND TO FOLLOWING INSTRUCTIONS
//!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//grf.wd
`define GRF_wd_ALUout 0
`define GRF_wd_DMrd 1
`define GRF_wd_PC8 2
`define GRF_wd_HILOout 3

`define GRF_wd_MAX_DIGITS 4

//alu.num2
`define ALU_num2_GRFrd2 0
`define ALU_num2_EXTout 1

`define ALU_num2_MAX_DIGITS 4


//time
`define Tuse_MAX 4'd15

//=====command opcodes=====
`define OP_RType 6'b000000
`define OP_addi 6'b001000
`define OP_andi 6'b001100
`define OP_ori 6'b001101
`define OP_lb 6'b100000
`define OP_lh 6'b100001
`define OP_lw 6'b100011
`define OP_sb 6'b101000
`define OP_sh 6'b101001
`define OP_sw 6'b101011
`define OP_beq 6'b000100
`define OP_bne 6'b000101
`define OP_lui 6'b001111
`define OP_jal 6'b000011

//=====command functs=====
`define R_add 6'b100000
`define R_sub 6'b100010
`define R_and 6'b100100
`define R_or 6'b100101
`define R_slt 6'b101010
`define R_sltu 6'b101011
`define R_mult 6'b011000
`define R_multu 6'b011001
`define R_div 6'b011010
`define R_divu 6'b011011
`define R_mfhi 6'b010000
`define R_mflo 6'b010010
`define R_mthi 6'b010001
`define R_mtlo 6'b010011
`define R_jr 6'b001000

`endif