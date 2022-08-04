USING System;
USING System.Math;
USING System.Alarm;
USING System.Timer;

USING Libs.Logics_v0_1_4;
USING Libs.Alarm_Mng_v1_1_5;

VAR_GLOBAL CONSTANT
    {REGION UPDATE EVERY TIME AN ALARM IS ADDEDD!}    
        (**Number of alarm saved inside ALARM table. 
         *NOTE: update every time an alarm is addedd!
        *)
        noAlrms : UINT := 50;
    {ENDREGION}
            
    {REGION ALARM LOG CONFIGURATION}
        (**Number of logs of alarms saved inside ALARM-LOG table*)
        noAlrmsLog     : UINT := 50; 
        (**
         *Size of the array VARs_TO_LOG.
         *Number of additionals variables saved inside ALARM-LOG table,
         *when an alarm is triggered (NOTE: used inside System.Alarm library)
        *)
        MaxAlarmValues : UINT := 1;
    {ENDREGION}
    
    {REGION Alarm widget description}
        (**Alarm descriptions*)
        AlarmDescr : ARRAY[1..noAlrms] OF STRING[66] := 
                                                       (*  |-------Row 1---------|-------Row 2---------|-------Row 3--------| *)
                                                           [    
                                                (*AL01*)   'System - RETAIN memory written too often.                         ',
                                                (*AL02*)   'System - NFC memory written too often.                            ',
                                                (*AL03*)   'U1-Probe Alarm                                                    ',
                                                (*AL04*)   'U2-Probe Alarm                                                    ',
                                                (*AL05*)   'U3-Probe Alarm                                                    ',
                                                (*AL06*)   'U4-Probe Alarm                                                    ',
                                                (*AL07*)   'U5-Probe Alarm                                                    ',
                                                (*AL08*)   'U6-Probe Alarm                                                    ',
                                                (*AL09*)   'U7-Probe Alarm                                                    ',
                                                (*AL10*)   'U8-Probe Alarm                                                    ',
                                                (*AL11*)   'U9-Probe Alarm                                                    ',
                                                (*AL12*)   'U10-Probe Alarm                                                   ',
                                                (*AL13*)   'DI1-Alarm                                                         ',
                                                (*AL14*)   'DI2-Alarm                                                         ',
                                                (*AL15*)   'DI3-Alarm                                                         ',
                                                (*AL16*)   'DI4-Alarm                                                         ',
                                                (*AL17*)   'DI5-Alarm                                                         ',
                                                (*AL18*)   'DI6-Alarm                                                         ',
                                                (*AL19*)   'DI7-Alarm                                                         ',
                                                (*AL20*)   'DI8-Alarm                                                         ',
                                                (*AL21*)   'DI9-Alarm                                                         ',
                                                (*AL22*)   'DI10-Alarm                                                        ',
                                                (*AL23*)   'U11-Probe Alarm                                                   ',
                                                (*AL24*)   'U12-Probe Alarm                                                   ',
                                                (*AL25*)   'U12-Probe Alarm                                                   ',
                                                (*AL26*)   'U12-Probe Alarm                                                   ',
                                                (*AL27*)   'cPCO1-Alarm                                                       ',
                                                (*AL28*)   'cPCO2-Alarm                                                       ',
                                                (*AL29*)   'cPCO3-Alarm                                                       ',
                                                (*AL30*)   'U1-Value Alarm                                                    ',
                                                (*AL31*)   'U2-Value Alarm                                                    ',
                                                (*AL32*)   'U3-Value Alarm                                                    ',
                                                (*AL33*)   'U4-Value Alarm                                                    ',
                                                (*AL34*)   'U5-Value Alarm                                                    ',
                                                (*AL35*)   'U6-Value Alarm                                                    ',
                                                (*AL36*)   'U7-Value Alarm                                                    ',
                                                (*AL37*)   'U8-Value Alarm                                                    ',
                                                (*AL38*)   'U9-Value Alarm                                                    ',
                                                (*AL39*)   'U10-Value Alarm                                                   ',
                                                (*AL40*)   'U11-Value Alarm                                                   ',
                                                (*AL41*)   'U12-Value Alarm                                                   ',
                                                (*AL42*)   'Display Connect Alarm                                             ',
                                                (*AL43*)   'BMS1 Connect Alarm                                                ',
                                                (*AL44*)   'ETH1 Connect Alarm                                                ',
                                                (*AL45*)   'Valve Driver Alarm                                                ',
                                                (*AL45*)   'S1 Alarm                                                          ',
                                                (*AL45*)   'S2 Alarm                                                          ',
                                                (*AL45*)   'S3 Alarm                                                          ',
                                                (*AL45*)   'S4 Alarm                                                          '
                                                           ];
        (**Stored variable 1 description*)
        StoreVarDesc1 : ARRAY[1..noAlrms] OF STRING[14]:=
                                                            [
                                                (*AL01*)    'Desc. Var1:',   
                                                (*AL02*)    'Desc. Var1:',
                                                (*AL03*)    'Desc. Var1:',
                                                (*AL04*)    'Desc. Var1:'
                                                            ];
        (**Stored variable 2 description*) //StoreVarDesc2
        StoreVarDesc2 : ARRAY[1..noAlrms] OF STRING[14]:=
                                                            [
                                                (*AL01*)    'Desc. Var2:',   
                                                (*AL02*)    'Desc. Var2:', 
                                                (*AL03*)    'Desc. Var2:',
                                                (*AL04*)    'Desc. Var2:'
                                                            ];
    {ENDREGION}
    
    
    {REGION CONFIGURE HERE YOUR ALARMs CATEGORY (max 16). YOU NEED TO USE "ActAlr_ForCategory".}
        (**Alarm category associate to ActAlr_ForCategory BIT_0 *) CAT_FREE_0            : UINT := 1;
        (**Alarm category associate to ActAlr_ForCategory BIT_1 *) CAT_AL_SRS_UNIT       : UINT := 2; 
        (**Alarm category associate to ActAlr_ForCategory BIT_2 *) CAT_AL_SRS_CIRC1      : UINT := 4; 
        (**Alarm category associate to ActAlr_ForCategory BIT_3 *) CAT_PROBES            : UINT := 8;     
        (**Alarm category associate to ActAlr_ForCategory BIT_4 *) CAT_WRG_REGUL         : UINT := 16; 
        (**Alarm category associate to ActAlr_ForCategory BIT_5 *) CAT_WRG_BOARD_MST     : UINT := 32; 
        (**Alarm category associate to ActAlr_ForCategory BIT_6 *) CAT_FREE_6            : UINT := 64; 
        (**Alarm category associate to ActAlr_ForCategory BIT_7 *) CAT_WRG_CIRC1         : UINT := 128; 
        (**Alarm category associate to ActAlr_ForCategory BIT_8 *) CAT_FREE_8            : UINT := 256; 
        (**Alarm category associate to ActAlr_ForCategory BIT_9 *) CAT_FREE_9            : UINT := 512; 
        (**Alarm category associate to ActAlr_ForCategory BIT_10*) CAT_WRG_HRSCOUNTER    : UINT := 1024;
        (**Alarm category associate to ActAlr_ForCategory BIT_11*) CAT_FREE_11           : UINT := 2048;
        (**Alarm category associate to ActAlr_ForCategory BIT_12*) CAT_FREE_12           : UINT := 4096;
        (**Alarm category associate to ActAlr_ForCategory BIT_13*) CAT_FREE_13           : UINT := 8192;
        (**Alarm category associate to ActAlr_ForCategory BIT_14*) CAT_FREE_14           : UINT := 16384;
        (**Alarm category associate to ActAlr_ForCategory BIT_15*) CAT_BLINK_KEY_SERVICE : UINT := 32768;
    {ENDREGION} 
END_VAR

VAR_GLOBAL PERSISTENT
    (**Log alarm array*)
    Log_Alarm  : ARRAY[1..noAlrmsLog] OF AlarmLog;
    (**Index of Log_Alarm *)
    LogAlrmIdx : UINT;
END_VAR

VAR_GLOBAL
    {REGION ALARMS MANAGEMENT}
        (**Container of Alarms table*)
        Alarms              : AlarmUnion;        
        (**Array of active alarms*)
        Active_Alrm         : ARRAY[1..noAlrms] OF UINT;        
        (**Active alarm status for each category, max 16 differents category (Bit15..Bit0)*)
        ActAlr_ForCategory  : WORD;   
    {ENDREGION}
    
    {REGION ALARM RESET}
        (**A request to reset all alarms is active (FALSE=NO, TRUE=Reset)*)
    	AlrmRes             : BOOL;
    	(**Reset active alarms by BMS net (FALSE=NO, TRUE=Reset)*)
    	ResAlrmByBMS        : BOOL;
    	(**Reset alarms by user interface (FALSE=NO, TRUE=Reset)*)
    	ResAlrmByHMI        : BOOL;
    {ENDREGION}
    
    {REGION ALARMS AND WARNINGS}
        {REGION ALARMS}
            (**RelayAlrm - Global alarm relay*)
        	RelayAlrm           : BOOL;    
            (**Please call the SERVICE, a serius alarm is present inside the unit*)
        	Al_Call_Service     : BOOL;
        	(**Miscellaneous alarms*)
        	Al_MiscAlrms        : BOOL;
        	(**Regulation alarms*)
        	Al_RegulationAlrms  : BOOL;
        	(**Serious alarm circ.1*)
        	Al_SrsCirc1         : BOOL;
        	(**Unit serious alarm*)
        	Al_SrsUnit          : BOOL;
        {ENDREGION}
    
        {REGION WARNINGS}
            (**Warning - Master board alarm*)
        	Wrg_BoardMst    : BOOL;
        	(**Warning - Circ.1 light alarm*)
        	Wrg_Circ1       : BOOL;
        	(**Warning - Hours counters alarm is active*)
        	Wrg_HrsCounters : BOOL;
        	(**Warning - Regulation alarm*)
        	Wrg_Regul       : BOOL;
        {ENDREGION}
    {ENDREGION}
    
    {REGION ALARMS LOG}
        (**Array of variables to store inside LOG_ALARM array, when an alarm happen*)
        VARs_TO_LOG : ARRAY[0..MaxAlarmValues] OF AlarmValue; 
        (**Empty structured used to clean LOG_ALARM array*)
        CleanLog    : AlarmLog;
        (**Alarms Log clear command (FALSE=No, TRUE=Yes)*)
    	LogAlrmRes  : BOOL;
    {ENDREGION}
END_VAR

VAR_GLOBAL INTERNAL
    (*Used by Modbus files transfer protocol*)
    AlrmInfoArr : ARRAY [1..noAlrms] OF AlarmInfo;
END_VAR



TYPE
    (**This structure manages all unit's alarms*)
    AlarmUnion : UNION
        (**Array of FBs Alarm_Req*)
        Arr   : ARRAY [1..noAlrms] OF Alarm_Req;
        (**Table of all alarms and them property*)
        Table : AlarmsStruct;
    END_UNION;
    
    (**List all alarms and them property (Code, Category, Reset type, ...)*)    
    AlarmsStruct : STRUCT           
            {REGION UNIT}
                (** A01 Unit - Retain memory saved too often*)                
                Al_RetainSavedTooOften : Alarm_Req := (StrCode := 'A01', Info := (Code := 001, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Manual));
                (** A02 Unit - NFC memory saved too often*)                
                Al_NFCSavedTooOften    : Alarm_Req := (StrCode := 'A02', Info := (Code := 002, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Manual));
                (** A03 Unit - Remote alarm by Din 1*)                
                Al_U1_PrbAlrm            : Alarm_Req := (StrCode := 'A03', Info := (Code := 003, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A04 Unit - Remote alarm by Din 1*)                
                Al_U2_PrbAlrm            : Alarm_Req := (StrCode := 'A04', Info := (Code := 004, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A05 Unit - Remote alarm by Din 1*)                
                Al_U3_PrbAlrm            : Alarm_Req := (StrCode := 'A05', Info := (Code := 005, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A06 Unit - Remote alarm by Din 1*)                
                Al_U4_PrbAlrm            : Alarm_Req := (StrCode := 'A06', Info := (Code := 006, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A07 Unit - Remote alarm by Din 1*)                
                Al_U5_PrbAlrm            : Alarm_Req := (StrCode := 'A07', Info := (Code := 007, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A08 Unit - Remote alarm by Din 1*)                
                Al_U6_PrbAlrm            : Alarm_Req := (StrCode := 'A08', Info := (Code := 008, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A09 Unit - Remote alarm by Din 1*)                
                Al_U7_PrbAlrm            : Alarm_Req := (StrCode := 'A09', Info := (Code := 009, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A10 Unit - Remote alarm by Din 1*)                
                Al_U8_PrbAlrm            : Alarm_Req := (StrCode := 'A10', Info := (Code := 010, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A11 Unit - Remote alarm by Din 1*)                
                Al_U9_PrbAlrm            : Alarm_Req := (StrCode := 'A11', Info := (Code := 011, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A12 Unit - Remote alarm by Din 1*)                
                Al_U10_PrbAlrm            : Alarm_Req := (StrCode := 'A12', Info := (Code := 012, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A13 Unit - Remote alarm by Din 1*)                
                Al_DI1Alrm            : Alarm_Req := (StrCode := 'A13', Info := (Code := 013, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A14 Unit - Remote alarm by Din 1*)               
                Al_DI2Alrm            : Alarm_Req := (StrCode := 'A14', Info := (Code := 014, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A15 Unit - Remote alarm by Din 1*)                
                Al_DI3Alrm            : Alarm_Req := (StrCode := 'A15', Info := (Code := 015, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A16 Unit - Remote alarm by Din 1*)                
                Al_DI4Alrm            : Alarm_Req := (StrCode := 'A16', Info := (Code := 016, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A17 Unit - Remote alarm by Din 1*)                
                Al_DI5Alrm            : Alarm_Req := (StrCode := 'A17', Info := (Code := 017, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A18 Unit - Remote alarm by Din 1*)                
                Al_DI6Alrm            : Alarm_Req := (StrCode := 'A18', Info := (Code := 018, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A19 Unit - Remote alarm by Din 1*)                
                Al_DI7Alrm            : Alarm_Req := (StrCode := 'A19', Info := (Code := 019, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A20 Unit - Remote alarm by Din 1*)                
                Al_DI8Alrm            : Alarm_Req := (StrCode := 'A20', Info := (Code := 020, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A21 Unit - Remote alarm by Din 1*)                
                Al_DI9Alrm            : Alarm_Req := (StrCode := 'A21', Info := (Code := 021, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A22 Unit - Remote alarm by Din 1*)                
                Al_DI10Alrm            : Alarm_Req := (StrCode := 'A22', Info := (Code := 022, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U11_PrbAlrm            : Alarm_Req := (StrCode := 'A23', Info := (Code := 023, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_U12_PrbAlrm            : Alarm_Req := (StrCode := 'A24', Info := (Code := 024, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A25 Unit - Room temperature probe alarm by Ain 1*)                
                Al_Ain1Alrm            : Alarm_Req := (StrCode := 'A25', Info := (Code := 025, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A26 Unit - Room temperature probe alarm by Ain 1*)                
                Al_HiTemp              : Alarm_Req := (StrCode := 'A26', Info := (Code := 026, Category := CAT_PROBES,   Reset := AlarmResetType#Auto));
                (** A27 Unit - Room temperature probe alarm by Ain 1*)                
                Al_cPCOe1ERR            : Alarm_Req := (StrCode := 'A27', Info := (Code := 027, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A28 Unit - Room temperature probe alarm by Ain 1*)                
                Al_cPCOe2ERR            : Alarm_Req := (StrCode := 'A28', Info := (Code := 028, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A28 Unit - Room temperature probe alarm by Ain 1*)                
                Al_cPCOe3ERR            : Alarm_Req := (StrCode := 'A29', Info := (Code := 029, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U1_ValAlrm            : Alarm_Req := (StrCode := 'A30', Info := (Code := 030, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_U2_valAlrm            : Alarm_Req := (StrCode := 'A31', Info := (Code := 031, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U3_ValAlrm            : Alarm_Req := (StrCode := 'A32', Info := (Code := 032, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_U4_ValAlrm            : Alarm_Req := (StrCode := 'A33', Info := (Code := 033, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U5_ValAlrm            : Alarm_Req := (StrCode := 'A34', Info := (Code := 034, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)               
                Al_U6_ValAlrm            : Alarm_Req := (StrCode := 'A35', Info := (Code := 035, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U7_ValAlrm            : Alarm_Req := (StrCode := 'A36', Info := (Code := 036, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_U8_ValAlrm            : Alarm_Req := (StrCode := 'A37', Info := (Code := 037, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U9_ValAlrm            : Alarm_Req := (StrCode := 'A38', Info := (Code := 038, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_U10_ValAlrm            : Alarm_Req := (StrCode := 'A39', Info := (Code := 039, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A23 Unit - Remote alarm by Din 1*)                
                Al_U11_ValAlrm            : Alarm_Req := (StrCode := 'A40', Info := (Code := 040, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_U12_ValAlrm            : Alarm_Req := (StrCode := 'A41', Info := (Code := 041, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A27 Unit - Room temperature probe alarm by Ain 1*)                
                Al_DisplayERR            : Alarm_Req := (StrCode := 'A42', Info := (Code := 042, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A27 Unit - Room temperature probe alarm by Ain 1*)                
                Al_BMS1ERR            : Alarm_Req := (StrCode := 'A43', Info := (Code := 043, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A27 Unit - Room temperature probe alarm by Ain 1*)                
                Al_ETH1ERR            : Alarm_Req := (StrCode := 'A44', Info := (Code := 044, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A27 Unit - Room temperature probe alarm by Ain 1*)                
                Al_ValveDriveERR      : Alarm_Req := (StrCode := 'A45', Info := (Code := 045, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_S1_Alrm            : Alarm_Req := (StrCode := 'A46', Info := (Code := 046, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_S2_Alrm            : Alarm_Req := (StrCode := 'A47', Info := (Code := 047, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_S3_Alrm            : Alarm_Req := (StrCode := 'A48', Info := (Code := 048, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
                (** A24 Unit - Remote alarm by Din 1*)                
                Al_S4_Alrm            : Alarm_Req := (StrCode := 'A49', Info := (Code := 049, Category := CAT_PROBES, Reset := AlarmResetType#Auto));
            {ENDREGION}

            (** -----------------------
                ADD HERE YOUR ALARMS!
            ---------------------------*)
    END_STRUCT;
END_TYPE


(**This program manages alarm categories and detects the alarms*) 
PROGRAM StoreAlarms
    VAR_TEMP
        (**Numeber of alarm active*)
        TotActAlm : UINT;
    END_VAR
    
    VAR
        (**Array index*)
        idx             : DINT;
                   
        (**Numeber of alarm active in previous cycle*)
        TotActAlm_Old   : UINT;
        
        TP_ResAlrmByBMS : TP;
        
        {REGION USED BY LOG-ALARM TO STORE THE "ADDITIONAL VARIABLES"} 
        (**A01 trigger used to store additional values*)
        RFtrg_Alr1       : RF_TRIG;
        (**A02 trigger used to store additional values*)
        RFtrg_Alr2       : RF_TRIG;
        (**A03 trigger used to store additional values*)
        RFtrg_Alr3       : RF_TRIG;
        (**A04 trigger used to store additional values*)
        RFtrg_Alr4       : RF_TRIG;
        {ENDREGION} 
    END_VAR
    
    {REGION RESET ALARM ARRAY}
        TP_ResAlrmByBMS(IN := ResAlrmByBMS, PT := T#5s);        (*Request of reset by BMS*)                 
        ResAlrmByBMS := TP_ResAlrmByBMS.Q;
    
        AlrmRes := ResAlrmByBMS OR ResAlrmByHMI;
    {ENDREGION}
    
    {REGION GET ACTIVE ALARMS}
        FOR idx := 1 TO UPPER_BOUND(Alarms.Arr, 1) DO
            {REGION IoT Third Parts Integration: Alarms retrieve via "Modbus File Transfer"}
                AlrmInfoArr[idx] := Alarms.Arr[idx].Info;       (*Copy the alarm info into a dedicated array*)
            {ENDREGION}
            
            {REGION "ADDITIONAL VARIABLES" stored inside LOG_ALARM array, when an alarm happen} 
                VARs_TO_LOG[0].USINT := 0;                      (* Cleaning of "additional variable" *)
                VARs_TO_LOG[1].USINT := 0;
            
                CASE idx OF
                    1:  (*SAVING ADDITIONAL INFO (e.g.: Pressure/Temperature)*)
                        RFtrg_Alr1(CLK := Alarms.Arr[idx].Info.Trigger);
                        
                        IF RFtrg_Alr1.Q THEN                                                
                            VARs_TO_LOG[0].REAL := Prg_InputMng.Ain1Val;
                            VARs_TO_LOG[1].REAL := 99.99;
                        END_IF;
                    
                    2:  (*SAVING ADDITIONAL INFO (e.g.: Error code/Temperature)*)
                        RFtrg_Alr2(CLK := Alarms.Arr[idx].Info.Trigger);
                        
                        IF RFtrg_Alr2.Q THEN
                            VARs_TO_LOG[0].REAL := Prg_InputMng.Ain1Val;
                            VARs_TO_LOG[1].REAL := 99.99;                           
                        END_IF; 
                    3:  (*SAVING ADDITIONAL INFO (e.g.: Pressure/Temperature)*)
                        RFtrg_Alr3(CLK := Alarms.Arr[idx].Info.Trigger);
                        
                        IF RFtrg_Alr3.Q THEN                                                
                            VARs_TO_LOG[0].REAL := Prg_InputMng.Ain1Val;
                            VARs_TO_LOG[1].REAL := 99.99;
                        END_IF;
                    
                    4:  (*SAVING ADDITIONAL INFO (e.g.: Error code/Temperature)*)
                        RFtrg_Alr4(CLK := Alarms.Arr[idx].Info.Trigger);
                        
                        IF RFtrg_Alr4.Q THEN
                            VARs_TO_LOG[0].REAL := Prg_InputMng.Ain1Val;
                            VARs_TO_LOG[1].REAL := 99.99;                           
                        END_IF;                                        
                END_CASE;
            {ENDREGION}
            
            Alarms.Arr[idx]
                            (    
                                DataVal         := VARs_TO_LOG, (* Remember to define ALARM_VALUES *)
                        	    AlrmRes         := AlrmRes,
                
                        	    Lst_ActAlrm     := Active_Alrm,
                        	    Lst_LogAlrm     := Log_Alarm,
                        	    Lst_LogAlrm_Idx := LogAlrmIdx
                            );
        END_FOR;
    {ENDREGION}    
       
    {REGION CLEAN THE LOG ARRAY}
        IF LogAlrmRes THEN 
            LogAlrmRes       := FALSE;
            (*RESTART LOG*)
            LogAlrmIdx := 0;
                
            (*CLEAR LOG LIST*)
            FOR idx := 1 TO TO_DINT(UPPER_BOUND(Log_Alarm, 1)) DO
                Log_Alarm[idx] := CleanLog;
            END_FOR;
        END_IF; 
    {ENDREGION}
          
    {REGION GET ALARM CATEGORIES}
        ActAlr_ForCategory := Alarm_Mng(Active_Alrm);
    
                        //    := ActAlr_ForCategory.0;                       // BIT n.0  ->       
        Al_SrsUnit            := ActAlr_ForCategory.1;                       // BIT n.1  -> CAT_AL_SRS_UNIT   
        Al_SrsCirc1           := ActAlr_ForCategory.2 OR Al_SrsUnit;         // BIT n.2  -> CAT_AL_SRS_CIRC1  
                        //    := ActAlr_ForCategory.3;                       // BIT n.3  -> 
        Wrg_Regul             := ActAlr_ForCategory.4;                       // BIT n.4  -> CAT_WRG_REGUL       
        Wrg_BoardMst          := ActAlr_ForCategory.5;                       // BIT n.5  -> CAT_WRG_BOARD_MST 
                        //    := ActAlr_ForCategory.6;                       // BIT n.6  ->  
        Wrg_Circ1             := ActAlr_ForCategory.7;                       // BIT n.7  -> CAT_WRG_CIRC1             
                        //    := ActAlr_ForCategory.8;                       // BIT n.8  ->      
                        //    := ActAlr_ForCategory.9;                       // BIT n.9  ->  
        Wrg_HrsCounters       := ActAlr_ForCategory.10;                      // BIT n.10 -> CAT_WRG_HRSCOUNTER
                        //    := ActAlr_ForCategory.11;                      // BIT n.11 ->                 
                        //    := ActAlr_ForCategory.12;                      // BIT n.12 ->     
                        //    := ActAlr_ForCategory.13;                      // BIT n.13 ->  
                        //    := ActAlr_ForCategory.14;                      // BIT n.14 ->  
        Al_Call_Service       := ActAlr_ForCategory.15;                      // BIT n.15 -> CAT_BLINK_KEY_SERVICE 
    {ENDREGION}
    
    {REGION MANAGEMENT OF ALARM RELAY}
        (*Depending on alarm relay configuration, the alarm relay is activated by serious alarms only or by all alarms (including devices maintenance, retain memory,...) *)
        
        Al_RegulationAlrms :=    Al_SrsUnit
                              OR Al_SrsCirc1
                              OR Wrg_Regul;
            
        Al_MiscAlrms :=    Wrg_BoardMst
                        OR Wrg_Circ1
                        OR Wrg_HrsCounters;
            
        RelayAlrm := Al_RegulationAlrms OR (AlarmRelayCfg AND Al_MiscAlrms); // Dout RELAY
    {ENDREGION}
            
    {REGION COUNT OF TOTAL ALARMs AND WARNINGs ACTIVE}
        FOR idx := 1 TO TO_DINT(UPPER_BOUND(Active_Alrm,1)) DO
            IF Active_Alrm[idx] >= 1 THEN 
                TotActAlm := TotActAlm + 1;
            END_IF;
        END_FOR;
        
        GblAlarm := UINT_TO_BOOL(TotActAlm);    
        
        (*LED-ALARM and BUZZER*)
        IF TotActAlm > TotActAlm_Old THEN
            Req_FixLED_Alarm   := FALSE;    // LED-ALARM on
            Req_BlinkLED_Alarm := TRUE;     // LED-ALARM is blinking
            BuzzerSilenced     := FALSE;    // Buzzer is buzzing
        END_IF;
        
        TotActAlm_Old := TotActAlm;
    {ENDREGION}       
END_PROGRAM