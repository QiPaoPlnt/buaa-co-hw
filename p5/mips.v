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

    //Here we listed all possible outputs, only to define them instead of actually "recording" them

    //IFU outputs
    wire [31:0] IFUpc0;
    wire [31:0] IFUpc4;
    wire [31:0] IFUpc8;
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

    //CMP outputs
    wire CMPout;
    
    //DM outputs
    wire [31:0] DMrd;

    //EXT outputs
    wire [31:0] EXTout;

    //Controller outputs
    //after how many ticks the value will be used
    //start counting from stage D
    wire [3:0] Tusers;
    wire [3:0] Tusert;
    //after how many ticks the value "has been" written into a register
    //start counting when it stepped right into stage E
    wire [3:0] Tnew;

    //should we pause the following command, for that we cannot decide whether or not
    //current command will write registers, and write to which register?
    wire GRFwaUnknown_initial;
    wire GRFwenUnknown_initial;

    //operation codes - can be filled into modules
    wire [(`IFU_NPC_DEFAULT_SIGNAL_DIGIT - 1) : 0] NPCop;
    wire GRFwen; //CHANGE: for multiple reg inputs
    wire [(`CMP_DEFAULT_SIGNAL_DIGIT - 1) : 0] CMPop;
    wire [(`ALU_DEFAULT_SIGNAL_DIGIT - 1) : 0] ALUop;
    wire DMwen; //CHANGE: for multiple RAM inputs
    wire [(`EXT_DEFAULT_SIGNAL_DIGIT - 1) : 0] EXTop;
        
    //connection selectors - only used in mux wires
    wire [(`IFU_valid_MAX_DIGITS - 1) : 0] IFUvalid;
    wire [(`IFU_value_MAX_DIGITS - 1) : 0] IFUvalue;
    wire [(`IFU_redirectValid_MAX_DIGITS - 1) : 0] IFUredirectValid;
    wire [(`GRF_wa_MAX_DIGITS - 1) : 0] GRFwa;
    wire [(`GRF_wd_MAX_DIGITS - 1) : 0] GRFwd;
    wire [(`ALU_num2_MAX_DIGITS - 1) : 0] ALUnum2;

    //control signals
    wire stall;

    //Define end

    //Stage Registers
    //a register is defined in a stage only when its data is recorded in this stage / inherited from previous stages

    //================ FETCH STAGE ================

    reg [31:0] RegF_IFUpc0; //produce
    reg [31:0] RegF_IFUpc8; //produce
    reg [31:0] RegF_IFUcommand; //produce
    reg [5:0] RegF_IFUopcode; //produce
    reg [4:0] RegF_IFUrs; //produce
    reg [4:0] RegF_IFUrt; //produce
    reg [4:0] RegF_IFUrd; //produce
    reg [4:0] RegF_IFUshamt; //produce
    reg [5:0] RegF_IFUfunct; //produce
    reg [15:0] RegF_IFUimm; //produce
    reg [25:0] RegF_IFUjump; //produce

    //================ DECODE STAGE ================

    reg [31:0] RegD_IFUpc0; //inherit
    reg [31:0] RegD_IFUpc8; //inherit
    reg [4:0] RegD_IFUrs; //inherit
    reg [4:0] RegD_IFUrt; //inherit
    reg [4:0] RegD_IFUrd; //inherit
    reg [3:0] RegD_Tnew; //produce
    reg RegD_GRFwaUnknown;
    reg RegD_GRFwenUnknown;
    reg [31:0] RegD_GRFrd1; //produce
    reg [31:0] RegD_GRFrd2; //produce
    reg [(`GRF_wa_MAX_DIGITS - 1) : 0] RegD_GRFwa; //produce
    reg [4:0] RegD_chooseGRFwa; //produce
    reg [(`GRF_wd_MAX_DIGITS - 1) : 0] RegD_GRFwd; //produce
    reg RegD_GRFwen; //produce
    reg [31:0] RegD_EXTout; //produce
    reg [(`ALU_DEFAULT_SIGNAL_DIGIT - 1) : 0] RegD_ALUop; //produce
    reg [(`ALU_num2_MAX_DIGITS - 1) : 0] RegD_ALUnum2; //produce
    reg RegD_DMwen; //produce

    //================ EXECUTE STAGE ================

    reg [31:0] RegE_IFUpc0; //inherit
    reg [31:0] RegE_IFUpc8; //inherit
    reg [4:0] RegE_IFUrs; //inherit
    reg [4:0] RegE_IFUrt; //inherit
    reg [4:0] RegE_IFUrd; //inherit
    reg [3:0] RegE_Tnew; //inherit
    reg RegE_GRFwaUnknown;
    reg RegE_GRFwenUnknown;
    reg [31:0] RegE_GRFrd1; //inherit
    reg [31:0] RegE_GRFrd2; //inherit
    reg [(`GRF_wa_MAX_DIGITS - 1) : 0] RegE_GRFwa; //inherit
    reg [4:0] RegE_chooseGRFwa; //inherit
    reg [(`GRF_wd_MAX_DIGITS - 1) : 0] RegE_GRFwd; //inherit
    reg RegE_GRFwen; //inherit
    reg RegE_DMwen; //inherit
    reg [31:0] RegE_ALUout; //produce

    //================ MEMORY STAGE ================

    reg [31:0] RegM_IFUpc0; //inherit
    reg [31:0] RegM_IFUpc8; //inherit
    reg [4:0] RegM_IFUrs; //inherit
    reg [4:0] RegM_IFUrt; //inherit
    reg [4:0] RegM_IFUrd; //inherit
    reg [3:0] RegM_Tnew; //inherit
    reg RegM_GRFwaUnknown;
    reg RegM_GRFwenUnknown;
    reg [(`GRF_wa_MAX_DIGITS - 1) : 0] RegM_GRFwa; //inherit
    reg [4:0] RegM_chooseGRFwa; //inherit
    reg [(`GRF_wd_MAX_DIGITS - 1) : 0] RegM_GRFwd; //inherit
    reg RegM_GRFwen; //inherit
    reg [31:0] RegM_ALUout; //inherit
    reg [31:0] RegM_DMrd; //produce

    //Stage registers end

    //Tuse & Tnew comparison
    //at stage D
    wire stall_rs = (RegF_IFUrs != 5'd0 &&
                    ((!RegD_GRFwenUnknown && !RegD_GRFwaUnknown && RegD_GRFwen && RegF_IFUrs == RegD_chooseGRFwa && Tusers < RegD_Tnew)
                    || (!RegE_GRFwenUnknown && !RegE_GRFwaUnknown && RegE_GRFwen && RegF_IFUrs == RegE_chooseGRFwa && Tusers < RegE_Tnew)
                    || (!RegM_GRFwenUnknown && !RegM_GRFwaUnknown && RegM_GRFwen && RegF_IFUrs == RegM_chooseGRFwa && Tusers < RegM_Tnew)));
    wire stall_rt = (RegF_IFUrt != 5'd0 &&
                    ((!RegD_GRFwenUnknown && !RegD_GRFwaUnknown && RegD_GRFwen && RegF_IFUrt == RegD_chooseGRFwa && Tusert < RegD_Tnew)
                    || (!RegE_GRFwenUnknown && !RegE_GRFwaUnknown && RegE_GRFwen && RegF_IFUrt == RegE_chooseGRFwa && Tusert < RegE_Tnew)
                    || (!RegM_GRFwenUnknown && !RegM_GRFwaUnknown && RegM_GRFwen && RegF_IFUrt == RegM_chooseGRFwa && Tusert < RegM_Tnew)));
    //we must pause operation of current command if we do not know
    //whether the last command will or will not write, and will write to which register
    //since we cannot be sure whether to forward or not
    wire stall_unknown_rs = (RegF_IFUrs != 5'd0 && Tusers != `Tuse_MAX && //first, validify whether rs, rt is in range
                    (((RegD_GRFwaUnknown && Tusers < RegD_Tnew)
                        || (RegE_GRFwaUnknown && Tusers < RegE_Tnew) //CHANGE: to avoid TLE, we should narrow the limits for the choices, e.g. if we want to write RegD/31, other registers should get passed
                        || (RegM_GRFwaUnknown && Tusers < RegM_Tnew)) //second, pause if we do not know where to write and will never know before we use it
                    || ((RegF_IFUrs == RegD_chooseGRFwa && RegD_GRFwenUnknown) //third, pause if we know it could be written and we do not whether to do or not
                        || (RegF_IFUrs == RegE_chooseGRFwa && RegE_GRFwenUnknown) 
                        || (RegF_IFUrs == RegM_chooseGRFwa && RegM_GRFwenUnknown)
                        )
                    ));
    wire stall_unknown_rt = (RegF_IFUrt != 5'd0 && Tusert != `Tuse_MAX && //first, validify whether rs, rt is in range
                    (((RegD_GRFwaUnknown && Tusert < RegD_Tnew)
                        || (RegE_GRFwaUnknown && Tusert < RegE_Tnew) 
                        || (RegM_GRFwaUnknown && Tusert < RegM_Tnew)) //second, pause if we do not know where to write and will never know before we use it
                    || ((RegF_IFUrt == RegD_chooseGRFwa && RegD_GRFwenUnknown) //third, pause if we know it could be written and we do not whether to do or not
                        || (RegF_IFUrt == RegE_chooseGRFwa && RegE_GRFwenUnknown) 
                        || (RegF_IFUrt == RegM_chooseGRFwa && RegM_GRFwenUnknown)
                        )
                    ));
    assign stall = stall_rs || stall_rt || stall_unknown_rs || stall_unknown_rt;

    //for potential flush operation
    wire flush_F = 0;

    //define stage register control signals
    wire PipeF_clear = reset || (!stall && flush_F); //flush activates only when the next command is surely about to going into stage F register
    wire PipeF_hold = stall;
    wire PipeD_clear = reset || stall;
    wire PipeD_hold = 0;
    wire PipeE_clear = reset;
    wire PipeE_hold = 0;
    wire PipeM_clear = reset;
    wire PipeM_hold = 0;

    //forward port for each stages

    //select corresponding writing value for each stage after
    function [31:0] selectPort(
        input [(`GRF_wd_MAX_DIGITS - 1) : 0] GRFwdPath,
        input [31:0] ALUout,
        input [31:0] DMrd,
        input [31:0] PC8
    );
        begin
            case(GRFwdPath)
                `GRF_wd_ALUout: selectPort = ALUout;
                `GRF_wd_DMrd: selectPort = DMrd;
                `GRF_wd_PC8: selectPort = PC8;
                default: selectPort = 2147483647; //still rediculous value
            endcase
        end
    endfunction

    //auto update for an input
    function [31:0] selectData(
        input [4:0] id,
        input [31:0] defaultData,
        //This will pass current stage, which will use registers bigger or equal to this stage
        //for example, a data selected at stage D will consider register of stage D, E, M
        //however, when we consider stage E, we will use register data of stage D & wires defined at stage E
        input [4:0] stage 
    );
        reg written;
        begin
            written = 1'b0;
            selectData = defaultData;
            if(id == 5'b0) begin
                written = 1'b1;
            end
            if(stage < `PIPE_STAGE_E && !written) begin // current < stage E
                if(!RegD_GRFwenUnknown && !RegD_GRFwaUnknown && RegD_GRFwen && RegD_chooseGRFwa == id && !RegD_Tnew) begin
                    selectData = selectPort(
                        RegD_GRFwd,
                        2147483647,
                        2147483647, //use rediculous value for impossible paths
                        RegD_IFUpc8
                    );
                    written = 1'b1;
                end
            end
            if(stage < `PIPE_STAGE_M && !written) begin // current < stage M
                if(!RegE_GRFwenUnknown && !RegE_GRFwaUnknown && RegE_GRFwen && RegE_chooseGRFwa == id && !RegE_Tnew) begin
                    selectData = selectPort(
                        RegE_GRFwd,
                        RegE_ALUout,
                        2147483647,
                        RegE_IFUpc8
                    );
                    written = 1'b1;
                end
            end
            if(stage < `PIPE_STAGE_W && !written) begin // current < stage W
                if(!RegM_GRFwenUnknown && !RegM_GRFwaUnknown && RegM_GRFwen && RegM_chooseGRFwa == id && !RegM_Tnew) begin
                    selectData = selectPort(
                        RegM_GRFwd,
                        RegM_ALUout,
                        RegM_DMrd,
                        RegM_IFUpc8
                    );
                    written = 1'b1;
                end
            end
        end
    endfunction

    //actual definition for forward ports of each stage's used values

    //These are actually wires, however, for always(...) we have to declare them as registers
    //stage D forwarding port
    reg [31:0] WireD_GRFrd1;
    reg [31:0] WireD_GRFrd2;
    
    //stage E forwarding port
    reg [31:0] WireE_GRFrd1;
    reg [31:0] WireE_GRFrd2;

    //stage M forwarding port
    reg [31:0] WireM_GRFrd1;
    reg [31:0] WireM_GRFrd2;

    always @(
        //since verilog does not support update when variables inside function were changed
        //we have to manually write all the related variables
        
        //function variables
        RegD_GRFwen, RegD_chooseGRFwa, RegD_Tnew, RegD_GRFwd, RegD_IFUpc8, 
        RegE_GRFwen, RegE_chooseGRFwa, RegE_Tnew, RegE_GRFwd, RegE_ALUout, RegE_IFUpc8,
        RegM_GRFwen, RegM_chooseGRFwa, RegM_Tnew, RegM_GRFwd, RegM_ALUout, RegM_DMrd, RegM_IFUpc8,

        
        //variable used to update forwarding wires
        RegF_IFUrs, GRFrd1,
        RegF_IFUrt, GRFrd2,
        RegD_IFUrs, RegD_GRFrd1,
        RegD_IFUrt, RegD_GRFrd2,
        RegE_IFUrs, RegE_GRFrd1,
        RegE_IFUrt, RegE_GRFrd2

    ) begin
        //stage D forwarding port
        WireD_GRFrd1 = selectData(RegF_IFUrs, GRFrd1, `PIPE_STAGE_D);
        WireD_GRFrd2 = selectData(RegF_IFUrt, GRFrd2, `PIPE_STAGE_D);

        //stage E forwarding port
        WireE_GRFrd1 = selectData(RegD_IFUrs, RegD_GRFrd1, `PIPE_STAGE_E);
        WireE_GRFrd2 = selectData(RegD_IFUrt, RegD_GRFrd2, `PIPE_STAGE_E);

        //stage M forwarding port
        WireM_GRFrd1 = selectData(RegE_IFUrs, RegE_GRFrd1, `PIPE_STAGE_M);
        WireM_GRFrd2 = selectData(RegE_IFUrt, RegE_GRFrd2, `PIPE_STAGE_M);
    end

    //Stage register update - after forwarding & stall

    //Register F
    always @(posedge clk) begin
        if(PipeF_clear) begin
            RegF_IFUpc0 <= 0;
            RegF_IFUpc8 <= 0;
            RegF_IFUcommand <= 0;
            RegF_IFUopcode <= 0;
            RegF_IFUrs <= 0;
            RegF_IFUrt <= 0;
            RegF_IFUrd <= 0;
            RegF_IFUshamt <= 0;
            RegF_IFUfunct <= 0;
            RegF_IFUimm <= 0;
            RegF_IFUjump <= 0;
        end
        else if(PipeF_hold) begin
        end
        else begin
            RegF_IFUpc0 <= IFUpc0;
            RegF_IFUpc8 <= IFUpc8;
            RegF_IFUcommand <= IFUcommand;
            RegF_IFUopcode <= IFUopcode;
            RegF_IFUrs <= IFUrs;
            RegF_IFUrt <= IFUrt;
            RegF_IFUrd <= IFUrd;
            RegF_IFUshamt <= IFUshamt;
            RegF_IFUfunct <= IFUfunct;
            RegF_IFUimm <= IFUimm;
            RegF_IFUjump <= IFUjump;
        end
    end

    //Register D

    //pre-selection for GRFwa to match valid Tuse
    wire [4:0] WireD_chooseGRFwa = (GRFwa == `GRF_wa_IFUrd) ? RegF_IFUrd :
                                (GRFwa == `GRF_wa_IFUrt) ? RegF_IFUrt : 
                                (GRFwa == `GRF_wa_31) ? 31 : RegF_IFUrd;

    wire WireD_chooseGRFwen = GRFwen;

    wire WireD_chooseGRFwaUnknown = GRFwaUnknown_initial;

    wire WireD_chooseGRFwenUnknown = GRFwenUnknown_initial;

    always @(posedge clk) begin
        if(PipeD_clear) begin
            RegD_IFUpc0 <= 0;
            RegD_IFUpc8 <= 0;
            RegD_IFUrs <= 0;
            RegD_IFUrt <= 0;
            RegD_IFUrd <= 0;
            RegD_Tnew <= 0;
            RegD_GRFwaUnknown <= 0;
            RegD_GRFwenUnknown <= 0;
            RegD_GRFrd1 <= 0;
            RegD_GRFrd2 <= 0;
            RegD_GRFwa <= 0;
            RegD_chooseGRFwa <= 0;
            RegD_GRFwd <= 0;
            RegD_GRFwen <= 0;
            RegD_EXTout <= 0;
            RegD_ALUop <= 0;
            RegD_ALUnum2 <= 0;
            RegD_DMwen <= 0;
        end
        else if(PipeD_hold) begin
        end
        else begin
            RegD_IFUpc0 <= RegF_IFUpc0;
            RegD_IFUpc8 <= RegF_IFUpc8;
            RegD_IFUrs <= RegF_IFUrs;
            RegD_IFUrt <= RegF_IFUrt;
            RegD_IFUrd <= RegF_IFUrd;
            RegD_Tnew <= Tnew; //We start counting when it stepped into stage E, so we just do not modify it now
            RegD_GRFwaUnknown <= WireD_chooseGRFwaUnknown;
            RegD_GRFwenUnknown <= WireD_chooseGRFwenUnknown;
            RegD_GRFrd1 <= WireD_GRFrd1;
            RegD_GRFrd2 <= WireD_GRFrd2;
            RegD_GRFwa <= GRFwa;
            RegD_chooseGRFwa <= WireD_chooseGRFwa;
            RegD_GRFwd <= GRFwd;
            RegD_GRFwen <= WireD_chooseGRFwen;
            RegD_EXTout <= EXTout;
            RegD_ALUop <= ALUop;
            RegD_ALUnum2 <= ALUnum2;
            RegD_DMwen <= DMwen;
        end
    end

    wire [4:0] WireE_chooseGRFwa = (RegD_GRFwa == `GRF_wa_IFUrd) ? RegD_IFUrd :
                                (RegD_GRFwa == `GRF_wa_IFUrt) ? RegD_IFUrt : 
                                (RegD_GRFwa == `GRF_wa_31) ? 31 : RegD_IFUrd;

    wire WireE_chooseGRFwen = RegD_GRFwen;

    wire WireE_chooseGRFwaUnknown = RegD_GRFwaUnknown;

    wire WireE_chooseGRFwenUnknown = RegD_GRFwenUnknown;

    //Register E
    always @(posedge clk) begin
        if(PipeE_clear) begin
            RegE_IFUpc0 <= 0;
            RegE_IFUpc8 <= 0;
            RegE_IFUrs <= 0;
            RegE_IFUrt <= 0;
            RegE_IFUrd <= 0;
            RegE_Tnew <= 0;
            RegE_GRFwaUnknown <= 0;
            RegE_GRFwenUnknown <= 0;
            RegE_GRFrd1 <= 0;
            RegE_GRFrd2 <= 0;
            RegE_GRFwa <= 0;
            RegE_chooseGRFwa <= 0;
            RegE_GRFwd <= 0;
            RegE_GRFwen <= 0;
            RegE_DMwen <= 0;
            RegE_ALUout <= 0;
        end
        else if(PipeE_hold) begin
        end
        else begin
            RegE_IFUpc0 <= RegD_IFUpc0;
            RegE_IFUpc8 <= RegD_IFUpc8;
            RegE_IFUrs <= RegD_IFUrs;
            RegE_IFUrt <= RegD_IFUrt;
            RegE_IFUrd <= RegD_IFUrd;
            RegE_Tnew <= `F_POSDEC(RegD_Tnew);
            RegE_GRFwaUnknown <= WireE_chooseGRFwaUnknown;
            RegE_GRFwenUnknown <= WireE_chooseGRFwenUnknown; //this is supposed to get changed, since we should modify its value at every stage to decide if it has already been decided or not
            RegE_GRFrd1 <= WireE_GRFrd1;
            RegE_GRFrd2 <= WireE_GRFrd2;
            RegE_GRFwa <= RegD_GRFwa;
            RegE_chooseGRFwa <= WireE_chooseGRFwa;
            RegE_GRFwd <= RegD_GRFwd;
            RegE_GRFwen <= WireE_chooseGRFwen;
            RegE_DMwen <= RegD_DMwen;
            RegE_ALUout <= ALUout;
        end
    end

    wire [4:0] WireM_chooseGRFwa = (RegE_GRFwa == `GRF_wa_IFUrd) ? RegE_IFUrd :
                                (RegE_GRFwa == `GRF_wa_IFUrt) ? RegE_IFUrt : 
                                (RegE_GRFwa == `GRF_wa_31) ? 31 : RegE_IFUrd;

    wire WireM_chooseGRFwen = RegE_GRFwen;

    wire WireM_chooseGRFwaUnknown = RegE_GRFwaUnknown;

    wire WireM_chooseGRFwenUnknown = RegE_GRFwenUnknown;

    //Register M
    always @(posedge clk) begin
        if(PipeM_clear) begin
            RegM_IFUpc0 <= 0;
            RegM_IFUpc8 <= 0;
            RegM_IFUrs <= 0;
            RegM_IFUrt <= 0;
            RegM_IFUrd <= 0;
            RegM_Tnew <= 0;
            RegM_GRFwaUnknown <= 0;
            RegM_GRFwenUnknown <= 0;
            RegM_GRFwa <= 0;
            RegM_chooseGRFwa <= 0;
            RegM_GRFwd <= 0;
            RegM_GRFwen <= 0;
            RegM_ALUout <= 0;
            RegM_DMrd <= 0;
        end
        else if(PipeM_hold) begin
        end
        else begin
            RegM_IFUpc0 <= RegE_IFUpc0;
            RegM_IFUpc8 <= RegE_IFUpc8;
            RegM_IFUrs <= RegE_IFUrs;
            RegM_IFUrt <= RegE_IFUrt;
            RegM_IFUrd <= RegE_IFUrd;
            RegM_Tnew <= `F_POSDEC(RegE_Tnew);
            RegM_GRFwaUnknown <= WireM_chooseGRFwaUnknown;
            RegM_GRFwenUnknown <= WireM_chooseGRFwenUnknown; //this is supposed to get changed, since we should modify its value at every stage to decide if it has already been decided or not
            RegM_GRFwa <= RegE_GRFwa;
            RegM_chooseGRFwa <= WireM_chooseGRFwa;
            RegM_GRFwd <= RegE_GRFwd;
            RegM_GRFwen <= WireM_chooseGRFwen;
            RegM_ALUout <= RegE_ALUout;
            RegM_DMrd <= DMrd;
        end
    end

    //Module connections
    //They can connect to multiple-staged registers, for they can have multiple functions in different stages


    //IFU

    //operations at stage D - use current data produced in stage D & register data of stage F
    //IFUvalid and IFUvalue are produced in stage D

    wire chooseIFUvalid = (IFUvalid == `IFU_valid_CMPout) ? CMPout :
                                (IFUvalid == `IFU_valid_1) ? 1 : CMPout;

    wire [31:0] chooseIFUvalue = (IFUvalue == `IFU_value_IFUimm) ? RegF_IFUimm :
                                (IFUvalue == `IFU_value_IFUjump) ? RegF_IFUjump :
                                (IFUvalue == `IFU_value_GRFrd1) ? WireD_GRFrd1 : RegF_IFUimm;
    
    wire chooseIFUredirectValid = (IFUredirectValid == `IFU_redirectValid_0) ? 0 :
                                (IFUredirectValid == `IFU_redirectValid_CMPout) ? CMPout : 0;
    
    ifu ifu(
        .clk(clk),
        .reset(reset),
        //Params at Stage D
        .stall(stall),
        .NPCop(NPCop), //PC(branch got) -> PC+4(NPCop decided) -> PC+8(actually jumped), this executes at PC+8, so PC+4 will natually be delay slot
        .NPCvalid(chooseIFUvalid),
        .NPCvalue(chooseIFUvalue),
        .NPCredirectValid(chooseIFUredirectValid),
        .NPCredirectTarget(RegF_IFUpc0),
        //Outputs at Stage F
        .pc0(IFUpc0),
        .pc4(IFUpc4),
        .pc8(IFUpc8),
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


    //GRF, EXT, CMP, & Controller

    //operations at stage W - use current data produced in stage W & register data of stage M
    wire [31:0] chooseGRFwd = (RegM_GRFwd == `GRF_wd_ALUout) ? RegM_ALUout :
                                (RegM_GRFwd == `GRF_wd_DMrd) ? RegM_DMrd : 
                                (RegM_GRFwd == `GRF_wd_PC8) ? RegM_IFUpc8 : RegM_ALUout;

    grf grf(
        .clk(clk),
        .reset(reset),
        //Params at Stage D
        .ra1(RegF_IFUrs),
        .ra2(RegF_IFUrt),
        //Params at Stage W
        .wa(RegM_chooseGRFwa),
        .wd(chooseGRFwd),
        .wen(RegM_GRFwen),
        //required for output
        .pc(RegM_IFUpc0),
        //Outputs at stage D
        .rd1(GRFrd1),
        .rd2(GRFrd2)
    );

    ext ext(
        .imm(RegF_IFUimm),
        .op(EXTop),
        //Outputs
        .out(EXTout)
    );

    cmp cmp(
        .num1(WireD_GRFrd1),
        .num2(WireD_GRFrd2),
        .op(CMPop),
        //Outputs
        .out(CMPout)
    );

    controller controller(
        .opcode(RegF_IFUopcode),
        .funct(RegF_IFUfunct),
        //Outputs
        .Tusers(Tusers),
        .Tusert(Tusert),
        .Tnew(Tnew),
        .GRFwaUnknown_initial(GRFwaUnknown_initial),
        .GRFwenUnknown_initial(GRFwenUnknown_initial),
        .NPCop(NPCop),
        .GRFwen(GRFwen),
        .CMPop(CMPop),
        .ALUop(ALUop),
        .DMwen(DMwen),
        .EXTop(EXTop),
        .IFUvalid(IFUvalid),
        .IFUvalue(IFUvalue),
        .IFUredirectValid(IFUredirectValid),
        .GRFwa(GRFwa),
        .GRFwd(GRFwd),
        .ALUnum2(ALUnum2)
    );


    //ALU

    //operations at stage E - use current data produced in stage E & register data of stage D
    wire [31:0] chooseALUnum2 = (RegD_ALUnum2 == `ALU_num2_GRFrd2) ? WireE_GRFrd2 :
                                (RegD_ALUnum2 == `ALU_num2_EXTout) ? RegD_EXTout : WireE_GRFrd2;

    alu alu(
        .num1(WireE_GRFrd1),
        .num2(chooseALUnum2),
        .op(RegD_ALUop),
        .out(ALUout)
    );


    //DM

    dm dm(
        .clk(clk),
        .reset(reset),
        .ra(RegE_ALUout),
        .wa(RegE_ALUout),
        .wd(WireM_GRFrd2),
        .wen(RegE_DMwen),
        //required for output
        .pc(RegE_IFUpc0),
        .rd(DMrd)
    );

endmodule
