USING System.UI;
USING System.IO;
USING System.EVD;
USING Libs.AinMng_v1_0_14; 
USING libs.EVD_EVO_PosVlvs;

(* USING System.GwWifi; *)
USING System.RemoteIO;
USING System.Net.Plan;
USING System.Timer;
USING System.Text;
USING System;
USING System.Math;
USING System.PowerManagement;
USING System.Encoding;
USING System.NVRAM;
USING System.FileSystem;
USING System.FileSystem.Enums;
     

(* Constant defines *)
{DEFINE VALVE_NUM  2}
{DEFINE VALVE_MAX_VAL 1000}
{DEFINE VALVE_STATUS_INIT 0}
{DEFINE VALVE_STATUS_ZEROING 1}
{DEFINE VALVE_STATUS_OPER 2}
{DEFINE VALVE_STATUS_TEST_FAST_OPEN 3}
{DEFINE VALVE_STATUS_TEST_FAST_CLOSE 4}

//{DEFINE U_INPUT_NUM  12}
{DEFINE U_INPUT_NUM  16}
{DEFINE A_OUT_NUM  5}
{DEFINE D_OUT_NUM  13}
{DEFINE D_IN_NUM  10}

{DEFINE OUT_0_10V_HMI 254}

{DEFINE TEST_TIME_TIME 1000 }

TYPE
    (** I/O config *)
	InputConfigT : STRUCT      		        
		IType : USINT;      
        Mode : USINT;
        Filter : USINT;
		IMax,Imin : real;
	END_STRUCT;
END_TYPE

VAR_GLOBAL RETAIN
   SystemInited : BOOL;  
   InputConfig : ARRAY[1..U_INPUT_NUM] OF InputConfigT;
   DOutStatus : ARRAY[1..D_OUT_NUM] OF BOOL:=[TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE];       
   AOutValue : ARRAY[1..A_OUT_NUM] OF REAL :=[5.0,6.0,8.0,5.0,6.0];     
   UniAOutValue : ARRAY[1..U_INPUT_NUM] OF INT (0..1000);
   EvdAutoSwing : bool; 
   EvdAutoSwingRandom : bool;  
   { METADATA MAX_VAL 7}   
   { METADATA MIN_VAL 0}         
   RGB_LedStatus : INT; /* b2=R, b1=G, b0=B */   
   GatewayOnOff : BOOL; 
   Enable7SegLedToggle : bool; 
   SegLedStat : bool; 
   { METADATA MAX_VAL 500}   
   { METADATA MIN_VAL 1}    
   EvdAutoSwingSteps : INT;  
   EnableTestTimer : bool := FALSE;
END_VAR

VAR_GLOBAL RETAIN
 RetainTestBuffer1 : ARRAY[1..1000] OF BYTE;  
 RetainTestMaxIdx : uint:=0; 
END_VAR


VAR_GLOBAL 
 FirstCycle : bool := TRUE;  
 EvdAutoSwingFast : bool:=TRUE; 
 Cpcoe1_Err,Cpcoe2_Err,Cpcoe3_Err,Display_Err,BMS1_Err,ETH1_Err : BOOL;
 cPCOe1_ErrCode, cPCOe2_ErrCode, cPCOe3_ErrCode : INT;
 cPCOe1_CH1Val, cPCOe2_CH1Val, cPCOe3_CH1Val : REAL;
 InputValueI : ARRAY [1..U_INPUT_NUM] OF INT;      
 InputValueR : ARRAY [1..U_INPUT_NUM] OF REAL;         
 DInputValue : ARRAY [1..D_IN_NUM] OF BOOL;  
 DefaultDInputValue : ARRAY [1..D_IN_NUM] OF BOOL := [FALSE, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE];
    
 Evd_struct: ARRAY [1..VALVE_NUM] OF TEEV;
 Evd_status : ARRAY [1..VALVE_NUM] OF USINT;  
 Evd_instance : UNIPVLV_DRV;
 Evd_last_exec : ARRAY [1..VALVE_NUM] OF UDINT;
 Evd_Alm:ARRAY [1..2] OF BOOL;
         
 EVD_EVO_DevCfg : Libs.EVD_EVO_PosVlvs_v1_0_2.CFG_EVD;
 EVD_EVO_TypEEV : libs.EVD_EVO_PosVlvs_v1_0_2.EXV_VALVE:=libs.EVD_EVO_PosVlvs_v1_0_2.EXV_VALVE#CAREL_EXV;
 { METADATA MAX_VAL 1000}   
 { METADATA MIN_VAL 0}  
 EVD_EVO_PositionA_Msk : UINT;
 { METADATA MAX_VAL 1000}   
 { METADATA MIN_VAL 0}  
 EVD_EVO_PositionB_Msk : UINT;
 EVD_EVO_AutoSwingFast : BOOL:=TRUE;
 EVD_EVO_S1Value, EVD_EVO_S2Value, EVD_EVO_S3Value, EVD_EVO_S4Value : REAL;
 EVD_EVO_PositionA, EVD_EVO_PositionB, EVD_EVO_CurPositionA, EVD_EVO_CurPositionB, EVD_EVO_AutoStatusA, EVD_EVO_AutoStatusB: UINT;
 EVD_EVO_VarPositionB, EVD_EVO_VarPositionA,EVD_EVO_DevErr : INT;
 EVD_EVO_EEVParams : libs.EVD_Emb_Basic_v1_0_0.TEEV_PARAMS;
 EVD_EVO_Alr : libs.EVD_EVO_PosVlvs_v1_0_2.EVD_ALR;
 EVD_EVO_MBSErr : Libs.EVD_EVO_PosVlvs_v1_0_2.ModbusErrors;
 EVD_EVO_IO : Libs.EVD_EVO_PosVlvs_v1_0_2.EVD_IO;
 EVD_EVO_Ready,EVD_EVO_Online, EVD_EVO_Offline, EVD_EVO_ExV_Carel,EVD_EVO_SingleTwin,EVD_EVO_isEvdTwin,EVD_EVO_MstOffVlvClosed,EVD_EVO_S1Alarm,EVD_EVO_S2Alarm,EVD_EVO_S3Alarm,EVD_EVO_S4Alarm : BOOL;
 
 Evd_position : ARRAY [1..VALVE_NUM] OF INT (0..1000);    
 AinAlarms:ARRAY [0..40] OF BOOL;
 EVD_EVOinstance : EvdEvo_PosVlvs;
       
 InputValAlarms:ARRAY [0..40] OF BOOL;
 { METADATA MAX_VAL 1000}   
 { METADATA MIN_VAL 0}      
 
 CurrentIOInfo: fwinfo;   
 MyUUID : LWORD; 
 MyUUID_H : DWORD;
 MyUUID_L : DWORD;   
 MyUUID_STR : ARRAY[1..16] OF BYTE; 
 MyUUID_S :  STRING;  
 CurrentChipIoErrorInfo : ChipIoErrorInfo; 
 ChipIoErrorCfg : ARRAY [1..5] OF UDINT(0..999);
 ChipIoErrorCrc : ARRAY [1..5] OF UDINT(0..999);
 ChipIoErrorNoasw : ARRAY [1..5] OF UDINT(0..999);    
 ChipIoErrorExcep : ARRAY [1..5] OF UDINT(0..999);        
 ChipIoErrorConsec : ARRAY [1..5] OF UDINT(0..999);        
 ChipIoErrorCfgNolim : ARRAY [1..5] OF UDINT;
 ChipIoErrorCrcNolim : ARRAY [1..5] OF UDINT;
 ChipIoErrorNoaswNolim : ARRAY [1..5] OF UDINT;    
 ChipIoErrorExcepNolim : ARRAY [1..5] OF UDINT;        
 ChipIoErrorConsecNolim : ARRAY [1..5] OF UDINT;        
 
 TotalChipIoError : uint;   
    
 ErrorInfoLen : int;   
    
 Ctime : DATE_AND_TIME;   
 LYear, LMonth, LDay, LHour, LMin, LSec, LMs : UINT;   
 WorkingTime :  UDINT;
 { METADATA MAX_VAL 60}   
 { METADATA MIN_VAL 0}   
 WorkingTimeSec : UINT;    
 WorkingTimeMin : UINT;  
 ToggleTime : UDINT;   
 Toggle : bool;   
    
// HeosSlaveSim_1: HeosSlaveSim; 
 (*InverterCpu_01 : InverterCpu;     
 InverterSecur_02 : InverterSecur;     *)
 Cpcoe_1, Cpcoe_2, Cpcoe_3 : Cpcoe;
 ValveProbe : VavleDriver_probe;
// InvMotor_01 : MBM_TMPL_PWRP_uMOTOR;
// InvSafe_02 : MBM_TMPL_PWRP_uSAFE;    
    
 pCOE_input_1 : INT;   
 ComStatusFb1Slave : BOOL;
 ComErrorFb1Slave : UINT;
 ComStatusFb2Inverter1 : BOOL;
 ComErrorFb2Inverter1 : UINT;
 ComStatusFb2Inverter2 : BOOL;
 ComErrorFb2Inverter2 : UINT;
 DisplayIsOnline : bool; 
    
 EvdAutoSwingValue : INT;  
  
    
 EvdAutoSwingUp : BOOL;   
 EvdSwingTimer : UDINT;       
 
 VersionStr : STRING;   
    
 PowerSupplyState : UINT;
 { METADATA MAX_VAL 999}   
 { METADATA MIN_VAL 0}    
 PowerSupplyFrequency : UINT;
   
   
// deviceType:UINT;(* device model *)
// boardType:UINT;(* board type *)
// machineType:UINT; (* Target machine type *)   
// hwCode:UINT;   (* Target hardware code *)   
    
HwInfo : HardwareDescription;  
OemInfoD : OemInfo;    
OemID_String1: STRING;
OemID_String2: STRING;
OVOemID_String1: STRING;
OVOemID_String2: STRING; 
  
Infos:  ProductInfo;    
    
RetainBusErrorCount : uint; 
RetainWrIndex : uint;
RetainTestEnableWr : bool;    
RetainTestEnableWrPrev : bool;    
RetainTestEnableRd : bool;            
RetainWrErrorCount : uint;    
    
NVRAMTestEnable : bool;
NVRAMTestCurrIdx : udint;    
NVVRAMErrorCount : uint;    
NVRAMError : DINT;  
NV_Data:BYTE ;       
NV_ValueChange : usint;  
    
NAND_FileTestEnable : bool;    
NAND_FileTestStatus : usint :=0;
Nand_FileBaseName: STRING:='EmcTestFile';  
Nand_FileName : STRING;    
NandFileID : DINT;  
NandFileWrSize : DINT;    
NandFileBuffer:ARRAY [1..5000] OF BYTE;
NandFileErrorCount : uint;   
NandFileCnfErrorCount : uint;       
NandFileOpenErrorCount : uint;           
NandFileWriteErrorCount : uint;               
NandFileIndex : int;
    

TestTimer : UDINT;    
TestTimerFirstCycle : bool := TRUE;    
RetainIsBusy : bool;    
END_VAR

VAR_GLOBAL 
IR_113_DCBusVoltage : int;
END_VAR


TYPE DisplayStatus:
(
    SEARCH_SEV_SEGMENTS,
    SEARCH_PLAN,
    SEV_SEGMENTS,
    PLAN
);
END_TYPE
VAR_GLOBAL
    mDisplayInfo : Remote_HMIInfo;
    termConfig : UDINT;
    sevSegTon : TON;
    pgd1Ton : TON;        
    commissioningToolConnected : BOOL;
    status : DisplayStatus := DisplayStatus#SEARCH_PLAN;
    BothTermOffline : TON;
END_VAR


(* Default values *)
FUNCTION LoadDefault : BOOL
    VAR_INPUT Restore : BOOL;    
    END_VAR
    VAR
        i : INT;   
    END_VAR
    IF NOT SystemInited THEN
        SystemInited := TRUE;  
    (* custom init for EMC test setup *)    
    FOR i:=1 TO U_INPUT_NUM  DO
        
        CASE i OF 
         1,2,4,5,7,10,11,12,14,15,16:    
            InputConfig[i].IType := LIB_IO_PROBE_NTC;
         3,13:    
            InputConfig[i].IType := LIB_IO_PROBE_0_5V;
            InputConfig[i].IMax := 5.0;
            InputConfig[i].Imin:=  0.0;
         8:    
            InputConfig[i].IType := LIB_IO_PROBE_0_10V;
            InputConfig[i].IMax := 10.0;
            InputConfig[i].Imin:=  0.0;
         6:    
            InputConfig[i].IType := LIB_IO_PROBE_0_1V;
            InputConfig[i].IMax := 1.0;
            InputConfig[i].Imin:=  0.0;
         9:   
            InputConfig[i].IType := LIB_IO_PROBE_4_20MA; 
            InputConfig[i].IMax := 20.0;
            InputConfig[i].Imin:=  4.0; 
        END_CASE;
        (*InputConfig[i].IType := LIB_IO_PROBE_NTC;*)
        InputConfig[i].Mode := LIB_IO_AIN;
        InputConfig[i].Filter := 5;
//        InputConfig[i].IMax := 100.0;
//        InputConfig[i].Imin:=  0.0;
        
    END_FOR;
    END_IF;   
EvdAutoSwingSteps := 1;  
LoadDefault:=TRUE;    
END_FUNCTION    


(* Manages pGD1 <> 7 seg switch: return true if at least one display is alive *)
(**
 *
 *
 *                                                       -------------------
 *                              ----------------------->|      Search 7     |<------------------------<------
 *                             |              ----------|      segments     |---------               |       |
 *                             |             |           -------------------          |              |       |
 *                             |             |                                        |              |       |
 *                             |             |                                        |              |       |
 *                          NO |         YES |                                        | NO           | NO    |
 *                             |             |                                        |              |       |
 *                             |             |                                        |              |       |
 *                             |            \|/                                      \|/             |       |
 *                             |    -------------------                      -------------------     |       | NO
 *                              ---|         7         |                 ---|      Search       |---         |
 *                                 |      segments     |                |   |       pLan        |            |
 *                                  -------------------                 |    -------------------             |                                
 *                                                                      |                                    |
 *                                                                  YES |                                    |
 *                                                                      |                                    |
 *                                                                      |                                    |
 *                                                                     \|/                                   |
 *                                                             -------------------                           |
 *                                                            |        pLan       |-------------------------
 *                                                            |                   |
 *                                                             ------------------- 
 *
 *
*)

FUNCTION DisplayAutoSwitch : BOOL
   
   /* Check if there is a commissioning tool connected on serial display */
    IF IsCommissioningToolPresent() = TRUE AND GetConnectionChannel() = TO_DINT(Serial.Serial_Channel#Serial0) THEN
        commissioningToolConnected := TRUE;
    ELSE
        commissioningToolConnected := FALSE;
    END_IF;
    
    CASE status OF
        DisplayStatus#SEARCH_SEV_SEGMENTS:
            Display.Start();
            GetDisplayInfo(mDisplayInfo);
            sevSegTon(IN := mDisplayInfo.Alive = FALSE AND commissioningToolConnected = FALSE, PT := t#5s);
            IF sevSegTon.Q THEN
                Display.Stop();
                status := DisplayStatus#SEARCH_PLAN;
                sevSegTon(IN := FALSE);
            ELSIF mDisplayInfo.Alive = TRUE OR commissioningToolConnected = TRUE THEN
                status := DisplayStatus#SEV_SEGMENTS;
                sevSegTon(IN := FALSE);
            END_IF;
        
        DisplayStatus#SEARCH_PLAN:
            termConfig := GetNetTerminalConfiguration();
            pgd1Ton(IN := termConfig = 0, PT := t#10s);
            IF pgd1Ton.Q THEN
                status := DisplayStatus#SEARCH_SEV_SEGMENTS;
                pgd1Ton(IN := FALSE);
            ELSIF termConfig > 0 THEN
                status := DisplayStatus#PLAN;
                pgd1Ton(IN := FALSE);
            END_IF;
        DisplayStatus#SEV_SEGMENTS:
            GetDisplayInfo(mDisplayInfo);
            IF mDisplayInfo.Alive = FALSE AND commissioningToolConnected = FALSE THEN
                status := DisplayStatus#SEARCH_SEV_SEGMENTS;
            END_IF;
        DisplayStatus#PLAN:
            termConfig := GetNetTerminalConfiguration();
            IF termConfig = 0 THEN
                status := DisplayStatus#SEARCH_SEV_SEGMENTS;
            END_IF;
    END_CASE; 
    
(* return true if at least one display is on-line *)    
DisplayAutoSwitch := mDisplayInfo.Alive OR (termConfig > 0);     
END_FUNCTION    






(************************************************************)
PROGRAM uPC2EMCMain
	(* Insert strategy here *)
VAR
    i : INT;
    tmpval : UDINT;
    Ain_Mng_1 :AinMng;
   
END_VAR;

   Display.Init(FALSE);
   Display.Read();
   Display.Write();   
     
    
  (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)  
  (* First Cycle *)  
  IF FirstCycle THEN 
     FirstCycle := FALSE; 
     SetPlanAddress(1); 
      
     IOGetFwInfo (CurrentIOInfo); 
     LoadDefault(FALSE);   
     
     (* convert version information *)   
     CurrentIOInfo.chip[1].fw := CurrentIOInfo.chip[1].fw MOD 256 + (CurrentIOInfo.chip[1].fw / 256)*100;
     CurrentIOInfo.chip[2].fw := CurrentIOInfo.chip[2].fw MOD 256 + (CurrentIOInfo.chip[2].fw / 256)*100;
     CurrentIOInfo.chip[3].fw := CurrentIOInfo.chip[3].fw MOD 256 + (CurrentIOInfo.chip[3].fw / 256)*100;
     CurrentIOInfo.chip[4].fw := CurrentIOInfo.chip[4].fw MOD 256 + (CurrentIOInfo.chip[4].fw / 256)*100;      
     CurrentIOInfo.chip[5].fw := CurrentIOInfo.chip[5].fw MOD 256 + (CurrentIOInfo.chip[5].fw / 256)*100;         
      
      
     MyUUID := ulint_to_LWORD(GetUniqueId());
     MyUUID_H := lword_to_DWORD(SHR(MyUUID,32));
     MyUUID_L := lword_to_DWORD(MyUUID); 
     System.Encoding.HEX_TO_STRING(MyUUID_STR, 1, 8, MyUUID_H); 
     System.Encoding.HEX_TO_STRING(MyUUID_STR, 9, 8, MyUUID_L);
     FOR i:=1 TO 16 DO 
      MyUUID_S := MyUUID_S + char_to_string(BYTE_TO_CHAR(MyUUID_STR[i]));
     END_FOR;
      
 
  (* Remove  just for test*)    
  (*IOGetFwInfo (CurrentIOInfo);*)
  GetHardwareDescription(HwInfo);
   
  (* Get and convert OEM Infos *)    
  System.GetOemInfo(OemInfoD); 
  OemID_String1 := '';    
  OemID_String2 := '';
  FOR i:=4 TO 1 BY -1 DO  
      OemID_String1 := OemID_String1 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OemID[i] & BYTE#15));
  END_FOR;
  FOR i:=6 TO 5 BY-1 DO 
      OemID_String1 := OemID_String1 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OemID[i] & BYTE#15));
  END_FOR;        
  FOR i:=8 TO 7 BY-1 DO 
      OemID_String1 := OemID_String1 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OemID[i] & BYTE#15));
  END_FOR;                 
      
  FOR i:=dint_to_int(UPPER_BOUND(OemInfoD.OemID,1)/2+1) TO dint_to_int(UPPER_BOUND(OemInfoD.OemID,1)) DO 
      OemID_String2 := OemID_String2 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OemID[i] & BYTE#15));
  END_FOR;

  OVOemID_String1 := '';    
  OVOemID_String2 := '';
  FOR i:=4 TO 1 BY -1 DO 
      OVOemID_String1 := OVOemID_String1 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OV_OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OV_OemID[i] & BYTE#15));
  END_FOR;
      
  FOR i:=6 TO 5 BY -1 DO 
      OVOemID_String1 := OVOemID_String1 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OV_OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OV_OemID[i] & BYTE#15));
  END_FOR;    
  FOR i:=8 TO 7 BY -1 DO 
      OVOemID_String1 := OVOemID_String1 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OV_OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OV_OemID[i] & BYTE#15));
  END_FOR; 
      
      
  FOR i:=dint_to_int(UPPER_BOUND(OemInfoD.OV_OemID,1)/2+1) TO dint_to_int(UPPER_BOUND(OemInfoD.OV_OemID,1)) DO 
      OVOemID_String2 := OVOemID_String2 + char_to_string(HEX_TO_STRING(shr(OemInfoD.OV_OemID[i],4))) + char_to_string(HEX_TO_STRING( OemInfoD.OV_OemID[i] & BYTE#15));
  END_FOR;
      
      
      
     (** I/O configure: copy HMI values to configuration structures *)
     (** Univesal I/O **) 
     FOR i:=1 TO TO_INT(CurrentIOInfo.U)  DO
         IF(InputConfig[i].IType <> OUT_0_10V_HMI) THEN 
           uConfig[i].mode_type:=InputConfig[i].IType;
           uConfig[i].mode_sel := InputConfig[i].Mode;              
           uConfig[i].filter := InputConfig[i].Filter;
         ELSE
           (** Out 0-10V **)  
           uConfig[i].mode_sel := LIB_IO_AOUT; 
           uConfig[i].mode_type := LIB_IO_OUT_0_10V;
         END_IF;
         
     END_FOR;    
    (** Y output **)
     FOR i:=1 TO TO_INT(CurrentIOInfo.Y)  DO
       yConfig[i].mode_type:= LIB_IO_OUT_0_10V; 
     END_FOR;    
      
      
     
     VersionStr := CONCAT(TO_STRING(__PROJ_VER_MAJOR__), '.');
     VersionStr := CONCAT(VersionStr, TO_STRING(__PROJ_VER_MINOR__));
    
    (* get product code from Topological EEprom *)  
    System.GetProductInfo(Infos);
     
      
   // System.SetNameSetting('HeosBox0');   removed
   
   //  PROVA := System.Net.TcpIp.GetIPHostname( );
   
      EVD_EVO_isEvdTwin := TRUE;
      EVD_EVO_MstOffVlvClosed := FALSE;
//      EVD_EVO_TypEEV := Libs.EVD_EVO_PosVlvs_v1_0_2.EXV_VALVE#CAREL_EXV;
//      EVD_EVO_IO.RelayA_Command := TRUE;
//      EVD_EVO_IO.RelayB_Command := TRUE;
      
  END_IF; (* First cycle *)

    
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)     
 (* Display Autoswitch pgd1 / LED *)  
  DisplayIsOnline:=DisplayAutoSwitch();   

 (* toogles a variable just to make led in 7Seg display blinking*)    
 IF( System.GetSystemTime() - ToggleTime > 1000 ) THEN
    ToggleTime:=System.GetSystemTime();
     
     IF Enable7SegLedToggle THEN 
       Toggle :=NOT(Toggle);     
     END_IF;     
         
 END_IF;
 
    
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)         
 (* U input configure and read to int*)    
  FOR i:=1 TO TO_INT(CurrentIOInfo.U)  DO 
      IF( InputConfig[i].IType <> OUT_0_10V_HMI ) THEN 
    
       //IF(uConfig[i].mode_type<>InputConfig[i].IType) THEN
        uConfig[i].mode_type := InputConfig[i].IType;
        uConfig[i].mode_sel  := LIB_IO_AIN;
       //END_IF;  
          
        Ain_Mng_1(
            Ain       := U[i].r,
            AinType   := InputConfig[i].IType,	
            PrbOffset := 0.0,
            MinVal:=InputConfig[i].Imin,
            MaxVal:=InputConfig[i].Imax,
            En_Ain    := TRUE,
            PrbVal    => InputValueR[i],
            PrbAlrm   => AinAlarms[i]
        );
      ELSE      
       uConfig[i].mode_type := LIB_IO_OUT_0_10V;   
       uConfig[i].mode_sel  := LIB_IO_AOUT;  
       Uout[i] := int_to_uint(UniAOutValue[i]);
      END_IF;    
  END_FOR;
    
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Dig Out*)   
 (* When EnableTestTimer is true NO 1 is used as timer measure output *)
  IF NOT EnableTestTimer  THEN 
   FOR i:=1 TO TO_INT(CurrentIOInfo.NO) DO  
        NO[i] := DOutStatus[i]; 
   END_FOR; 
  END_IF;    

 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Dig input*)            
  FOR i:=1 TO TO_INT(CurrentIOInfo.ID) DO  
      DInputValue[i] := ID[i]; 
  END_FOR;  
  IF EVD_EVOinstance.DeviceEvdEvo.Info.isOnline THEN
      DInputValue[5] :=NOT EVD_EVO_IO.DI1_Status;
      DInputValue[6] :=NOT EVD_EVO_IO.DI2_Status;
  END_IF;
    
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Analog out input*)                
  FOR i:=1 TO TO_INT(CurrentIOInfo.Y)  DO 
    Y[i] :=TO_UINT(AOutValue[i]*100.0);
  END_FOR;   
    
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Serial port*)                
//   Supervisor_BMS2.Init();
//   Supervisor_BMS2.Read(); 
   pCOWeb_BMS1.Init();
   pCOWeb_BMS1.Read();  

   MS_LocalNet.Init();
   MS_LocalNet.Read();
   
//   InverterLine.Init();
//   InverterLine.Read();     
      
   Supervisor_ETH1.Init();
   Supervisor_ETH1.Read();    
    
    
    Line_cPCOe2.Init();
    Line_cPCOe2.Read();
    
    Line_cPCOe3.Init();
    Line_cPCOe3.Read();

(*Update variables here*)

    
    
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Valve init and update*)                 
   FOR i:=1 TO VALVE_NUM DO     
    CASE Evd_status[i] OF
       VALVE_STATUS_INIT: 
        Evd_status[i] := VALVE_STATUS_ZEROING;
        Evd_struct[i].Enable := 1;    
        Evd_struct[i].PositionToSet := 0;       
        Evd_struct[i].PositionToSet := 0;
        Evd_struct[i].CurrentEstimatedPosition := 0;    
        Evd_struct[i].VariationToSet := -500;           
        Evd_struct[i].ClosingSteps := 500;
        Evd_struct[i].MaxSteps := 480; (* or con 0x4000 per half steps *)
        Evd_struct[i].MinSteps := 0; (* not used *)   
        Evd_struct[i].NominalCurrent := 350; (* not used *)
        Evd_struct[i].HoldingCurrent := 50;  (* not used *)
        Evd_struct[i].DutyCycle := 30;
        Evd_struct[i].ClosingXSteps := 1; (* not used *)
        Evd_struct[i].DutyCycleEnable := 1;
        Evd_struct[i].FastClosingSpeed := 150;
        Evd_struct[i].FastClosingSpeedEnable := 1;
        Evd_struct[i].OpeningXSteps := 1; (* not used *)
        Evd_struct[i].Speed := 50; 
        Evd_last_exec[i]:=System.GetSystemTime();	    
       VALVE_STATUS_ZEROING: 
        IF Evd_struct[i].CurrentEstimatedPosition  = 0  AND (System.GetSystemTime() - Evd_last_exec[i]) > 4000 THEN;
           Evd_status[i] := VALVE_STATUS_OPER;     
        END_IF;    
        
       VALVE_STATUS_OPER:        
        IF EvdAutoSwingFast THEN 
           Evd_status[i] := VALVE_STATUS_TEST_FAST_OPEN;        
        END_IF;
        
         IF EvdAutoSwing THEN           
           tmpval := INT_TO_UDINT(EvdAutoSwingValue);
           tmpval := (tmpval *  UINT_TO_UDINT(Evd_struct[i].MaxSteps)) / VALVE_MAX_VAL;         
           Evd_struct[i].PositionToSet := UDINT_TO_UINT(tmpval); 
         ELSE       
          IF(Evd_position[i] >= VALVE_MAX_VAL) THEN
              Evd_position[i] := VALVE_MAX_VAL;
          END_IF;
        (*  IF(Evd_position[i] < 0) THEN
            Evd_position[i] := 0;
          END_IF;*)
        
          IF EvdAutoSwingRandom THEN      
            (* add random +- 75 value to current position *)  
            tmpval := INT_TO_UDINT(Evd_position[i] + real_to_int(150.0 * (System.Util.Random( ) - 0.5)) );
          ELSE      
            tmpval := INT_TO_UDINT(Evd_position[i]);  
          END_IF;        
          
          tmpval := (tmpval *  UINT_TO_UDINT(Evd_struct[i].MaxSteps)) / VALVE_MAX_VAL;                   
          Evd_struct[i].PositionToSet := UDINT_TO_UINT(tmpval); 
        
        END_IF;     
        
      VALVE_STATUS_TEST_FAST_OPEN:
        IF Evd_struct[i].CurrentEstimatedPosition = Evd_struct[i].MaxSteps THEN
           Evd_struct[i].PositionToSet := 0;     
           Evd_status[i] := VALVE_STATUS_TEST_FAST_CLOSE; 
        ELSE
           Evd_struct[i].PositionToSet := Evd_struct[i].MaxSteps;
        END_IF;
        IF NOT( EvdAutoSwingFast) THEN
            Evd_status[i] := VALVE_STATUS_OPER;     
        END_IF;
      
      VALVE_STATUS_TEST_FAST_CLOSE:  
        IF Evd_struct[i].CurrentEstimatedPosition = 0 THEN
           Evd_struct[i].PositionToSet := Evd_struct[i].MaxSteps;      
           Evd_status[i] := VALVE_STATUS_TEST_FAST_OPEN; 
          ELSE
           Evd_struct[i].PositionToSet := 0;  
        END_IF;
        IF NOT( EvdAutoSwingFast) THEN
            Evd_status[i] := VALVE_STATUS_OPER;     
        END_IF;
       END_CASE;
       
     Evd_instance(ValveNum := INT_TO_BYTE(i), EEVIN := Evd_struct[i]);
  END_FOR; 
     
    
    
  IF EvdAutoSwing THEN     
   IF( System.GetSystemTime() - EvdSwingTimer > 2 ) THEN
      EvdSwingTimer:=System.GetSystemTime();
 
      IF EvdAutoSwingUp AND  EvdAutoSwingValue  < 1000  THEN 
         EvdAutoSwingValue := EvdAutoSwingValue + (VALVE_MAX_VAL*EvdAutoSwingSteps)/(uint_to_int(Evd_struct[1].MaxSteps));       
      END_IF;
       
      IF NOT(EvdAutoSwingUp) AND  EvdAutoSwingValue  >= 1  THEN 
         EvdAutoSwingValue := EvdAutoSwingValue - (VALVE_MAX_VAL*EvdAutoSwingSteps)/(uint_to_int(Evd_struct[1].MaxSteps));        
      END_IF; 
      
      IF EvdAutoSwingValue >= 1000  THEN  
          EvdAutoSwingUp := FALSE;          
      END_IF;       
      IF EvdAutoSwingValue <= 0  THEN  
          EvdAutoSwingUp := TRUE;          
      END_IF;        
   END_IF;   
   
 END_IF;
    
    EVD_EVO_PositionA := EVD_EVO_PositionA_Msk * 480 / 1000;
    EVD_EVO_PositionB := EVD_EVO_PositionB_Msk * 480 / 1000;
    
    IF EVD_EVO_AutoSwingFast AND EVD_EVO_Ready THEN
        IF EVD_EVO_AutoStatusA=0 THEN
            EVD_EVO_AutoStatusA := 1;
        END_IF;
        IF EVD_EVO_AutoStatusB=0 THEN
            EVD_EVO_AutoStatusB := 1;
        END_IF;
        EVD_EVO_PositionA_Msk := 0;
        EVD_EVO_PositionA_Msk := 0;
        IF EVD_EVO_AutoStatusA=1 THEN
            IF EVD_EVO_CurPositionA=480 THEN
                EVD_EVO_PositionA := 0;
                EVD_EVO_AutoStatusA := 2;
            ELSE
                EVD_EVO_PositionA := 480;
            END_IF;
        END_IF;
        IF EVD_EVO_AutoStatusA=2 THEN
            IF EVD_EVO_CurPositionA=0 THEN
                EVD_EVO_PositionA := 480;
                EVD_EVO_AutoStatusA := 1;
            ELSE
                EVD_EVO_PositionA := 0;
            END_IF;
        END_IF;
        IF EVD_EVO_AutoStatusB=1 THEN
            IF EVD_EVO_CurPositionB=480 THEN
                EVD_EVO_PositionB := 0;
                EVD_EVO_AutoStatusB := 2;
            ELSE
                EVD_EVO_PositionB := 480;
            END_IF;
        END_IF;
        IF EVD_EVO_AutoStatusB=2 THEN
            IF EVD_EVO_CurPositionB=0 THEN
                EVD_EVO_PositionB := 480;
                EVD_EVO_AutoStatusB := 1;
            ELSE
                EVD_EVO_PositionB := 0;
            END_IF;
        END_IF;
    ELSE
        EVD_EVO_AutoStatusA := 0;
        EVD_EVO_AutoStatusB := 0;
    END_IF;
  
    
    EVD_EVOinstance(
        DevAddr_EVD                     := 198,
        DevCfg_EVD                      := EVD_EVO_DevCfg,
        TypEEV                          := EVD_EVO_TypEEV,
        ValveA_PositionToSet            := EVD_EVO_PositionA,
        ValveB_PositionToSet            := EVD_EVO_PositionB,
        IsEvdTwin                       := EVD_EVO_isEvdTwin,
        MstOfflineVlvClosed             := EVD_EVO_MstOffVlvClosed,
        En_FB                           := TRUE,
        ReadyToWork                     => EVD_EVO_Ready,
        ValveA_CurrentEstimatedPosition => EVD_EVO_CurPositionA,
        ValveA_VariationToSet           => EVD_EVO_VarPositionA,
        ValveB_CurrentEstimatedPosition => EVD_EVO_CurPositionB,
        ValveB_VariationToSet           => EVD_EVO_VarPositionB,
        EEV_Params                      => EVD_EVO_EEVParams,
        Alr                             => EVD_EVO_Alr,
        Online_EVD                      => EVD_EVO_Online,
        OfflineAlrm_EVD                 => EVD_EVO_Offline,
        ModbusErr                       => EVD_EVO_MBSErr,
        ExV_Carel_Universal_Vlv         => EVD_EVO_ExV_Carel,
        EVD_Single_Twin                 => EVD_EVO_SingleTwin,
        IO                              := EVD_EVO_IO
    );
    EVD_EVO_DevErr :=TO_INT(EVD_EVOinstance.DeviceEvdEvo.Info.DeviceError);
    ValveProbe.Vlv_Probe_S1_ALARM_ENABLE := TRUE;
    ValveProbe.Vlv_Probe_S2_ALARM_ENABLE := TRUE;
    ValveProbe.Vlv_Probe_S3_ALARM_ENABLE := TRUE;
    ValveProbe.Vlv_Probe_S4_ALARM_ENABLE := TRUE;
    ValveProbe.Vlv_Probe_S1_ALARM_DELAY := 10;
    ValveProbe.Vlv_Probe_S2_ALARM_DELAY := 10;
    ValveProbe.Vlv_Probe_S3_ALARM_DELAY := 10;
    ValveProbe.Vlv_Probe_S4_ALARM_DELAY := 10;
    ValveProbe.Vlv_Probe_S1_PROBE_TYPE := 1;
    ValveProbe.Vlv_Probe_S3_PROBE_TYPE := 1;
    ValveProbe.Vlv_Probe_S2_PROBE_TYPE := 4;
    ValveProbe.Vlv_Probe_S4_PROBE_TYPE := 4;
    ValveProbe.Vlv_Probe_S1_RANGE_MAX := 4.5;
    ValveProbe.Vlv_Probe_S1_RANGE_MIN := 0.5;
    ValveProbe.Vlv_Probe_S3_RANGE_MAX := 4.5;
    ValveProbe.Vlv_Probe_S3_RANGE_MIN := 0.5;
    ValveProbe.Vlv_Probe_S1_ALARM_THRESHOLD_HIGH := 5.3;
    ValveProbe.Vlv_Probe_S1_ALARM_THRESHOLD_LOW := 4.7;
    ValveProbe.Vlv_Probe_S2_ALARM_THRESHOLD_HIGH := 100;
    ValveProbe.Vlv_Probe_S2_ALARM_THRESHOLD_LOW := 0;
    ValveProbe.Vlv_Probe_S3_ALARM_THRESHOLD_HIGH := 5.3;
    ValveProbe.Vlv_Probe_S3_ALARM_THRESHOLD_LOW := 4.7;
    ValveProbe.Vlv_Probe_S4_ALARM_THRESHOLD_HIGH := 100;
    ValveProbe.Vlv_Probe_S4_ALARM_THRESHOLD_LOW := 0;
    EVD_EVO_S1Value := ValveProbe.Vlv_Probe_S1_VALUE;
    EVD_EVO_S2Value := ValveProbe.Vlv_Probe_S2_VALUE;
    EVD_EVO_S3Value := ValveProbe.Vlv_Probe_S3_VALUE;
    EVD_EVO_S4Value := ValveProbe.Vlv_Probe_S4_VALUE;
    EVD_EVO_S1Alarm := ValveProbe.Vlv_Probe_S1_ALARM;
    EVD_EVO_S2Alarm := ValveProbe.Vlv_Probe_S2_ALARM;
    EVD_EVO_S3Alarm := ValveProbe.Vlv_Probe_S3_ALARM;
    EVD_EVO_S4Alarm := ValveProbe.Vlv_Probe_S4_ALARM;
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Update clock variables *)                 
    
 System.timer.GetTime(Ctime);   
 System.Timer.SPLIT_DT(Ctime, LYear, LMonth, LDay, LHour, LMin, LSec, LMs);    
 WorkingTime:=System.GetSystemTime()/1000;   
 WorkingTimeSec := UDINT_TO_UINT((WorkingTime) MOD 60);
 WorkingTimeMin := UDINT_TO_UINT((WorkingTime) / 60);    
  
 (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)             
 (* Update chipIo error infos *)                    
 (* get chipIO cfg errors*)   
  
 TotalChipIoError := 0;      
 ErrorInfoLen:=IOGetChipIoErrorInfo(0,ChipIoErrorCfgNoLim);       
 FOR i:=1 TO 5 DO
  ChipIoErrorCfg[i] := ChipIoErrorCfgNoLim[i];  
  TotalChipIoError := TotalChipIoError + udint_to_uint(ChipIoErrorCfgNoLim[i]);
 END_FOR;
 (* get chipIO comm CRC  errors*)       
 ErrorInfoLen:=IOGetChipIoErrorInfo(1,ChipIoErrorCrcNoLim);       
 FOR i:=1 TO 5 DO
  ChipIoErrorCrc[i] := ChipIoErrorCrcNoLim[i];  
  TotalChipIoError := TotalChipIoError + udint_to_uint(ChipIoErrorCrcNoLim[i]);   
 END_FOR;
 (* get chipIO comm no answer  errors*)    
 ErrorInfoLen := IOGetChipIoErrorInfo(2, ChipIoErrorNoaswNoLim);
  FOR i:=1 TO 5 DO
  ChipIoErrorNoasw[i] := ChipIoErrorNoaswNoLim[i];
  TotalChipIoError := TotalChipIoError + udint_to_uint(ChipIoErrorNoaswNoLim[i]);
 END_FOR;  
 (* get chipIO comm exception  errors*)    
 ErrorInfoLen := IOGetChipIoErrorInfo(3, ChipIoErrorExcepNoLim);
 FOR i:=1 TO 5 DO
  ChipIoErrorExcep[i] := ChipIoErrorExcepNoLim[i];  
   TotalChipIoError := TotalChipIoError + udint_to_uint(ChipIoErrorExcepNoLim[i]);   
 END_FOR;   
    
 
    
// HeosSlaveSim_1.HoldingRegister_CH1_TYPE := 0;
// pCOE_input_1 := HeosSlaveSim_1.HoldingRegister_CH1_VALUE;
// ComStatusFb1Slave  := HeosSlaveSim_1.Info.IsOnline;
// ComErrorFb1Slave := HeosSlaveSim_1.Info.ErrorsCount;
    Cpcoe_1.UnivChs_ChTyp[1] := 0;
    Cpcoe_1.DOuts_VALUE[1] := 1;
    cPCOe1_CH1Val := Cpcoe_1.UnivChs_VALUE[1];
    Cpcoe_2.UnivChs_ChTyp[1] := 0;
    Cpcoe_2.DOuts_VALUE[1] := 1;
    cPCOe2_CH1Val := Cpcoe_2.UnivChs_VALUE[1];
    Cpcoe_3.UnivChs_ChTyp[1] := 0;
    Cpcoe_3.DOuts_VALUE[1] := 1;
    cPCOe3_CH1Val := Cpcoe_3.UnivChs_VALUE[1];
    
    
    

(*Update variables here*)
(*InverterCpu_01.HoldingRegister_0 := 0;
ComStatusFb2Inverter1:=InverterCpu_01.Info.IsOnline;    
ComErrorFb2Inverter1 := InverterCpu_01.Info.ErrorsCount;*)

    
//ComStatusFb2Inverter1:=InvMotor_01.Info.IsOnline;    
//ComErrorFb2Inverter1 := InvMotor_01.Info.ErrorsCount;
//ComStatusFb2Inverter2:=InvSafe_02.Info.IsOnline;    
//ComErrorFb2Inverter2 := InvSafe_02.Info.ErrorsCount;
    
    
MS_LocalNet.Write();           
//InverterLine.Write();  
//Supervisor_BMS2.Write();
pCOWeb_BMS1.Write();    
Supervisor_ETH1.Write();    
Line_cPCOe2.Write();
Line_cPCOe3.Write();
    
cPCOe1_ErrCode :=TO_INT(Cpcoe_1.Info.DeviceError);
cPCOe2_ErrCode:=TO_INT(Cpcoe_2.Info.DeviceError);
cPCOe3_ErrCode:=TO_INT(Cpcoe_3.Info.DeviceError);
Cpcoe1_Err := NOT Cpcoe_1.Info.isOnline OR cPCOe1_ErrCode <> 0;
Cpcoe2_Err := NOT Cpcoe_2.Info.isOnline OR cPCOe2_ErrCode <> 0;
Cpcoe3_Err := NOT Cpcoe_3.Info.isOnline OR cPCOe3_ErrCode <> 0;
//Display_Err := NOT Display.Info.Online;
BMS1_Err := NOT pCOWeb_BMS1.Info.Online;
ETH1_Err := NOT Supervisor_ETH1.Info.Online;
   
CASE  PowerManagement.GetPowerSupplyState() OF
    PowerSupplyState#UNKNOWN_PS: PowerSupplyState := 0;
    PowerSupplyState#AC_PS: PowerSupplyState := 1;
    PowerSupplyState#DC_PS: PowerSupplyState := 2;
    PowerSupplyState#AC_FAIL_PS: PowerSupplyState := 3;
    PowerSupplyState#DC_FAIL_PS: PowerSupplyState := 4;
END_CASE;
PowerSupplyfrequency := usint_to_uint(PowerManagement.GetPowerSupplyFrequency());
    
/* RGB led control */
//RGB.SetRGBLed(0,  int_to_byte(RGB_LedStatus/4 MOD 2), int_to_byte(RGB_LedStatus/2 MOD 2), int_to_byte(RGB_LedStatus MOD 2));    

/* Gateway ON/OFF */  
IF NOT EnableTestTimer  THEN     
 IF( GatewayOnOff = 1) THEN    
  SetGatewayWifiStatus(1);
 ELSE    
  SetGatewayWifiStatus(0);
 END_IF;
END_IF;

(*------------------------------------------------*)
(* Retrieve model information *)
GetModel(deviceType, boardType, machineType, hwCode);
    

(*------------------------------------------------*)
(* Gather retain EEprom error using custom Exception manager, frequent writings need to be activated *)    
IF (RetainTestEnableWr) THEN 
 
  (* When set enable a clear is forced *)  
  IF NOT(RetainTestEnableWrPrev) THEN
    FOR i:=1 TO dint_to_int(UPPER_BOUND(RetainTestBuffer1,1)) DO  
         RetainTestBuffer1[i] := 0;
    END_FOR;    
    RetainForceBackup();
    RetainTestEnableWrPrev := TRUE;  
  END_IF;  
 
 (* if exceptionmanger detects an write error on RETAIN RetainBusErrorCount is incremented*)   
 IF EEpRetainErrorOccurred THEN
   RetainBusErrorCount:=RetainBusErrorCount+1; 
   EEpRetainErrorOccurred := FALSE;
 END_IF;
    
    
 RetainWrIndex := RetainWrIndex + 1;   
 IF((RetainWrIndex < 1) OR (RetainWrIndex > dint_to_uint(UPPER_BOUND(RetainTestBuffer1,1))) ) 
  THEN 
     RetainWrIndex := 1; 
  END_IF;
    
 (* writes  Retain *) 
 RetainTestBuffer1[RetainWrIndex] := uint_to_byte(RetainWrIndex);
    
 IF(RetainTestMaxIdx < RetainWrIndex)  THEN 
   RetainTestMaxIdx:=RetainWrIndex;   
 END_IF;    

 RetainForceBackup();  
    
ELSE
 RetainTestEnableWrPrev := FALSE;     
END_IF; (* RetainTestEnable *)

(*    
IF RetainTestEnableRd THEN     
  RetainWrErrorCount := 0; 
  IF RetainTestMaxIdx > dint_to_uint(UPPER_BOUND(RetainTestBuffer1,1)) THEN
    RetainTestMaxIdx := dint_to_uint(UPPER_BOUND(RetainTestBuffer1, 1));
  END_IF;      
  FOR i:=1 TO uint_to_int(RetainTestMaxIdx) DO  
   IF(RetainTestBuffer1[i] <> int_to_byte(i) ) THEN
       RetainWrErrorCount := RetainWrErrorCount + 1;
      END_IF;   
  END_FOR;    
END_IF;   RetainTestEnableRd *)
    

(*------------------------------------------------*)
(* Gather NVRAM / FRAM read/write errors *)            
IF (NVRAMTestEnable) THEN     
    IF NVRAMTestCurrIdx >= NVRAM_GetSize() THEN
       NVRAMTestCurrIdx := 0; 
       NV_ValueChange := NV_ValueChange + 1;
        
    END_IF;   
  
    NVRAMError:=NVRAM_WriteVar(NVRAMTestCurrIdx,udint_to_byte(NVRAMTestCurrIdx+usint_to_udint(NV_ValueChange)));   
    IF NVRAMError <0 THEN        
      NVVRAMErrorCount := NVVRAMErrorCount + 1; 
    END_IF;  
    NVRAMError:=NVRAM_ReadVar(NVRAMTestCurrIdx,NV_Data);   
    IF NVRAMError <0 THEN        
      NVVRAMErrorCount := NVVRAMErrorCount + 1; 
    END_IF;  
    IF(NV_Data <> (udint_to_byte(NVRAMTestCurrIdx+usint_to_udint(NV_ValueChange)))) THEN
      NVVRAMErrorCount := NVVRAMErrorCount + 1; 
    END_IF;  
    NVRAMTestCurrIdx := NVRAMTestCurrIdx + 1;
END_IF;    
    
(*------------------------------------------------*)
(* Gather NAND read/write error *)            
IF NAND_FileTestEnable  THEN

 CASE  NAND_FileTestStatus OF
    0: (* create and write *)
      NandFileIndex := NandFileIndex + 1;
       IF( NandFileIndex > 10) THEN
          NandFileIndex := 1;
       END_IF;
      Nand_FileName := Nand_FileBaseName + int_to_string(NandFileIndex) + '.bin';
      NandFileID:=FileOpen(PartitionType#PublicPartition,Nand_FileName,FS_OpenMode#CREATE_RW);  
      IF NandFileID >= 0 THEN 
         FOR i:=1 TO dint_to_int(UPPER_BOUND(NandFileBuffer,1)) DO
             NandFileBuffer[i]:=int_to_byte(i);             
         END_FOR;
         NandFileWrSize:=FileWrite(NandFileID, NandFileBuffer); 
         IF(NandFileWrSize <> 5000) THEN 
             NandFileErrorCount := NandFileErrorCount + 1;
             NandFileWriteErrorCount := NandFileWriteErrorCount + 1;
         END_IF; 
         FileClose(NandFileID);
      ELSE
        NandFileErrorCount := NandFileErrorCount + 1;
        NandFileOpenErrorCount := NandFileOpenErrorCount + 1;
      END_IF;
      NAND_FileTestStatus := 1; 
     
    1: (* read and verify *)
      NandFileID:=FileOpen(PartitionType#PublicPartition,Nand_FileName,FS_OpenMode#OPEN_READ);   
      IF NandFileID >= 0 THEN 
        FOR i:=1 TO dint_to_int(UPPER_BOUND(NandFileBuffer,1)) DO
             NandFileBuffer[i]:=0;             
        END_FOR;
        FileRead(NandFileID, NandFileBuffer); 
        FOR i:=1 TO dint_to_int(UPPER_BOUND(NandFileBuffer,1)) DO
             IF( NandFileBuffer[i] <> int_to_byte(i)) THEN
                 NandFileErrorCount := NandFileErrorCount + 1;  
                 NandFileCnfErrorCount := NandFileCnfErrorCount + 1;
                 EXIT;
             END_IF;
        END_FOR;
       FileClose(NandFileID);     
      ELSE
        NandFileErrorCount := NandFileErrorCount + 1;                      
        NandFileOpenErrorCount := NandFileOpenErrorCount + 1;  
      END_IF;
      NAND_FileTestStatus := 0;     
END_CASE;
     
    
END_IF;    

(* When EnableTestTimer is true NO 1 and GatewayWifiStatus are used as timer measure outputs *)    
IF EnableTestTimer  THEN 
  tmpval := GetSystemTime() - TestTimer;    
  IF ( tmpval  >=  TEST_TIME_TIME ) THEN    
   
   IF TestTimerFirstCycle THEN 
       TestTimerFirstCycle := FALSE;
       tmpval := TEST_TIME_TIME;
   END_IF;   
   TestTimer := GetSystemTime() - (tmpval  -  TEST_TIME_TIME);  
      
   NO[1] := NOT NO[1];
   IF(NO[1]) THEN
      SetGatewayWifiStatus(1);
   ELSE
      SetGatewayWifiStatus(0); 
   END_IF;  
  END_IF;   
 ELSE
  TestTimerFirstCycle := TRUE;  
END_IF;       
    
   
(* Refresh UI *)
SendVirtualKey(NO_KEY, 1);
END_PROGRAM


