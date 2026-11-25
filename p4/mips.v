`timescale 1ns / 1ps

`include "defines.v"

//main module
//We will connect each module by recording each OUTPUT of them

//1. When you add a new command without any possible new items - simply modify controller.v
//2. When you add several new MUXes/signals - add signals in defines.v, add signals in controller.v, add MUXes in mips.v / add operations in alu/....v
//3. When you add new types of data - declare them in modules, add their operations, add signals in mips.v, and decide what is the input - if only 1 input, simply connect them; if more than 1, turn to step 2.
//4. When you add a new module - write it and declare it in mips.v, modify their connections, modify corresponding MUXes as instructed in step 2.
module mips(
        input clk,
        input reset
    );

    //IFU outputs
    wire [31:0] IFUpc0;
    wire [31:0] IFUpc4;
    wire [31:0] IFUcommand;
    wire [5:0] IFUopcode;
    wire [4:0] IFUrs;
    wire [4:0] IFUrt;
    wire [4:0] IFUrd;
    wire [4:0] IFUshamt;
    wire [5:0] IFUfunct;
    wire [15:0] IFUimm;
    wire [25:0] IFUjump;
    
    //GRF outputs
    wire [31:0] GRFrd1;
    wire [31:0] GRFrd2;

    //ALU outputs
    wire [31:0] ALUout;
    
    //DM outputs
    wire [31:0] DMrd;

    //EXT outputs
    wire [31:0] EXTout;

    //Controller outputs
    //operation codes - can be filled into modules
    wire [(`IFU_NPC_DEFAULT_SIGNAL_DIGIT - 1) : 0] NPCop;
    wire GRFwen; //CHANGE: for multiple reg inputs
    wire [(`ALU_DEFAULT_SIGNAL_DIGIT - 1) : 0] ALUop;
    wire DMwen; //CHANGE: for multiple RAM inputs
    wire [(`EXT_DEFAULT_SIGNAL_DIGIT - 1) : 0] EXTop;
        
    //connection selectors - only used in mux wires
    wire [(`IFU_valid_MAX_DIGITS - 1) : 0] IFUvalid;
    wire [(`IFU_value_MAX_DIGITS - 1) : 0] IFUvalue;
    wire [(`GRF_wa_MAX_DIGITS - 1) : 0] GRFwa;
    wire [(`GRF_wd_MAX_DIGITS - 1) : 0] GRFwd;
    wire [(`ALU_num2_MAX_DIGITS - 1) : 0] ALUnum2;


    //MUX
    wire chooseIFUvalid = (IFUvalid == `IFU_valid_ALUout) ? ALUout :
                                (IFUvalid == `IFU_valid_1) ? 1 : ALUout;
    wire [31:0] chooseIFUvalue = (IFUvalue == `IFU_value_IFUimm) ? IFUimm :
                                (IFUvalue == `IFU_value_IFUjump) ? IFUjump :
                                (IFUvalue == `IFU_value_ALUout) ? ALUout : IFUimm;
    wire [4:0] chooseGRFwa = (GRFwa == `GRF_wa_IFUrd) ? IFUrd :
                                (GRFwa == `GRF_wa_IFUrt) ? IFUrt : 
                                (GRFwa == `GRF_wa_31) ? 31 : IFUrd;
    wire [31:0] chooseGRFwd = (GRFwd == `GRF_wd_ALUout) ? ALUout :
                                (GRFwd == `GRF_wd_DMrd) ? DMrd : 
                                (GRFwd == `GRF_wd_PC4) ? IFUpc4 : ALUout;
    wire [31:0] chooseALUnum2 = (ALUnum2 == `ALU_num2_GRFrd2) ? GRFrd2 :
                                (ALUnum2 == `ALU_num2_EXTout) ? EXTout : GRFrd2;


    //modules - use values above!
    ifu ifu(
        .clk(clk),
        .reset(reset),
        .NPCop(NPCop),
        .NPCvalid(chooseIFUvalid),
        .NPCvalue(chooseIFUvalue),
        .pc0(IFUpc0),
        .pc4(IFUpc4),
        .command(IFUcommand),
        .opcode(IFUopcode),
        .rs(IFUrs),
        .rt(IFUrt),
        .rd(IFUrd),
        .shamt(IFUshamt),
        .funct(IFUfunct),
        .imm(IFUimm),
        .jump(IFUjump)
    );

    grf grf(
        .clk(clk),
        .reset(reset),
        .ra1(IFUrs),
        .ra2(IFUrt),
        .wa(chooseGRFwa),
        .wd(chooseGRFwd),
        .wen(GRFwen),
        //required for output
        .pc(IFUpc0),
        .rd1(GRFrd1),
        .rd2(GRFrd2)
    );

    alu alu(
        .num1(GRFrd1),
        .num2(chooseALUnum2),
        .op(ALUop),
        .out(ALUout)
    );

    dm dm(
        .clk(clk),
        .reset(reset),
        .ra(ALUout),
        .wa(ALUout),
        .wd(GRFrd2),
        .wen(DMwen),
        //required for output
        .pc(IFUpc0),
        .rd(DMrd)
    );

    ext ext(
        .imm(IFUimm),
        .op(EXTop),
        .out(EXTout)
    );

    controller controller(
        .opcode(IFUopcode),
        .funct(IFUfunct),
        .NPCop(NPCop),
        .GRFwen(GRFwen),
        .ALUop(ALUop),
        .DMwen(DMwen),
        .EXTop(EXTop),
        .IFUvalid(IFUvalid),
        .IFUvalue(IFUvalue),
        .GRFwa(GRFwa),
        .GRFwd(GRFwd),
        .ALUnum2(ALUnum2)
    );

endmodule
