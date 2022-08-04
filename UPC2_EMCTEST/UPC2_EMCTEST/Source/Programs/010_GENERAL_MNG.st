USING System;
USING System.UI;
USING System.NFC;
USING System.Logs;
USING System.Text;
USING System.NVRAM;
USING System.Timer;
USING System.Serial;
USING System.Globalization;

USING Libs.GetTime_v0_1_8;
USING Libs.Blackout_v2_0_1;

VAR_GLOBAL
    (**Client is deleting memory*)
    ClientDeletingMem : BOOL;    
END_VAR

PROGRAM Main
    VAR PUBLIC        
    END_VAR
    VAR
        (**Client waiting time, before to delete memory*)
        TON_ClientWaitBefroreDelMem  : TON;
        (**FB Blackout*)
        Blackout1            : Blackout;
        (**Info saved in NVRAM*)
        NVRAM_Info : DWORD;
        (**This program calls other programs*)
        Prg_ProgramsExecutor : ProgramsExecutor;
        (**Save current system time *)
        {ATTRIBUTE UOM MILLISECOND}
        MemTime              : UDINT;
        (**First cycle*)
        FirstCycleDone       : BOOL;        
        (**After restoring the memory to default, it waits 10s before restarting the PLC*)
        TON_WaitRestartPlc   : TON;
        (**R_TRIG Restore Default Settings*) 
        Rtrg_RestoreDefault  : R_TRIG;
        (**Local time used to set RTC by network*)
        NewLocTimeByNet      : DateTime;
        (**Timezone POSIX string*)
        TzPOSIX              : STRING;
        (**Settings feedback of TimeZone *)
        Err_TimeZone         : UINT;
        (**Settings feedback of LocalTime*)
        Err_LocalTime        : UINT;
        (**Settings feedback of SetTime*)
        Err_SetTime          : UINT;
        i                    : DINT;
    END_VAR    
    
    CurrSysT        := GetSystemTimeAdv();
    TaskMainCurrT   := GetTaskStartTimeAdv();
    TaskMainLiveCnt := GetTaskLiveCounter();
    RetainWrN       := TO_UDINT(GetRetainWritingsNumber());
    
    {REGION Read Date/Time}
        GetTime(TimeUTC);
        GetLocalTime(LocDateAndTime);
        GetLocalTime(LocTime);        
        CurrLocTime.Hour        := LocTime.Hour;
        CurrLocTime.Minute      := LocTime.Minute;
        CurrLocTime.Second      := LocTime.Second;
        CurrLocTime.Millisecond := LocTime.Millisecond;
        CurrLocTime.Day         := LocTime.Day;
        CurrLocTime.Month       := LocTime.Month;
        CurrLocTime.Year        := LocTime.Year;
        Day_Week                := DAY_OF_WEEK(LocTime);
    {ENDREGION}
    
    {REGION First cycle}    
        IF NOT FirstCycleDone THEN
            FirstCycleDone := TRUE;
            MemTime        := TaskMainCurrT;
            
            GetSystemInfo(SysInfo);
            GetHardwareDescription(HardwareInfo);
            GetModel(DeviceType, BoardType, MachineType, HwCode);
            GetProjectInfo(InfoProject);
            GetProductInfo(InfoProduct);
            GUID := SplitPrjGUID(InfoProject.ProjectID);
                        
            (*The PLC is enabled to start only after checking the product code*)
            Go_PLC := TRUE;

            {REGION Balckout}
                (*Read*)
                NVRAM_ReadVar(0, NVRAM_Info);
                PwrOffDate_NVRAM_BLKO := TO_UDINT(NVRAM_Info);
            {ENDREGION}            
            
            {REGION COMUNICATION IS STOPPED DURING INITIALIZATION OF INTERNAL PROTOCOLs STRUCTUREs.}
                (*BMS*)
//                Supervisor.Init(FALSE);
                (*Fieldbus*)
//                MBM_Line.Init(FALSE);
            {ENDREGION}
            
            {REGION IoT Third Parts Integration: Alarms retrieve via "Modbus File Transfer"}
               (*Following APIs calls are needed*)
                System.Alarm.AlarmInfoManagement(AlrmInfoArr);
                System.Alarm.AlarmLogManagement(LOG_ALARM);
            {ENDREGION}
        ELSE
            {REGION Balckout}
                (*Write*)
                NVRAM_Info := TO_DWORD(TO_UDINT(TimeUTC));
                NVRAM_WriteVar(0, NVRAM_Info);
                (*Read*)
                NVRAM_ReadVar(0, NVRAM_Info);
                PwrOffDate_NVRAM_BLKO :=  TO_UDINT(NVRAM_Info);
            {ENDREGION}
        END_IF;
    
        TaskMainExeT := TaskMainCurrT - MemTime;
        MemTime      := TaskMainCurrT;    
    {ENDREGION}
    
    Blackout1(
                PwrOffDate_NVRAM   := PwrOffDate_NVRAM_BLKO,
        
                OffMins            => OffMins_BLKO,
                OffHours           => OffHours_BLKO,
                OffDays            => OffDays_BLKO,
        
                LastOnSec          => LastOnSec_BLKO,
                LastOnMin          => LastOnMin_BLKO,
                LastOnHour         => LastOnHour_BLKO,
                LastOnDay          => LastOnDay_BLKO,
                LastOnMonth        => LastOnMonth_BLKO,
                LastOnYear         => LastOnYear_BLKO    
                );
    
    
    {REGION RESTORE PLC MEMORY TO DEFAULT SETTINGS}
        Rtrg_RestoreDefault(CLK := RestoreDefault);
        
        IF Rtrg_RestoreDefault.Q THEN           (*Saving BMS2 settings before restoring memory*)            
            BMS2_Addr_SavedRAM := BMS2_Addr;
            BMS2_Baud_SavedRAM := BMS2_Baud; 
            BMS2_Conf_SavedRAM := BMS2_Conf;            
        END_IF;    
        
        TON_ClientWaitBefroreDelMem(IN := RestoreDefault AND NOT ClientDeletingMem, PT := T#5s); (*NOTE: In a net "CLIENT + SERVER": server must receive the restore memory command -> then after a delay -> client can restore its memory*)
    
        IF TON_ClientWaitBefroreDelMem.Q THEN
            ClientDeletingMem := TRUE;            
            RetainRestoreDefault();             (*NOTE: This request will be executed at END of MAIN task.*)
        END_IF;    
    {ENDREGION}
           
    {REGION DATE AND TIME}
        {REGION SETTINGS pCO CLOCK TIME BY APPLICA}
            IF APPsCfgRTC.SetRTC THEN 
                APPsCfgRTC.SetRTC := FALSE;
                //Necessary and in this order
                Err_TimeZone := SetTimeZone(APPsCfgRTC.TimeZone);                
                Err_SetTime  := SetTime(APPsCfgRTC.DateTime);           (*APPLICA give UTC Time*)
                
                {REGION Saving of time ZONE when RTC set by APPs}
                    FOR i := LOWER_BOUND(TimeZonePOSIX, 1) TO UPPER_BOUND(TimeZonePOSIX, 1) DO
                        IF APPsCfgRTC.TimeZone = TimeZonePOSIX[i] THEN
                            Timezone := TO_UINT(i);
                            EXIT;
                        END_IF;                    
                    END_FOR;
                {ENDREGION}
            END_IF
        {ENDREGION};
    
        {REGION SETTINGS pCO CLOCK TIME BY USER NETWORK}
            IF SetClockByNet THEN
                SetClockByNet := FALSE;               
                
                NewLocTimeByNet.Day    := NewDateTimeByNet.Day;                 (*NOTE: Necessary to adjust TYPE to UINT*)
                NewLocTimeByNet.Month  := NewDateTimeByNet.Month;
                NewLocTimeByNet.Year   := NewDateTimeByNet.Year;
    
                NewLocTimeByNet.Hour   := NewDateTimeByNet.Hour;
                NewLocTimeByNet.Minute := NewDateTimeByNet.Minute;
                NewLocTimeByNet.Second := NewDateTimeByNet.Second;
                
                TzPOSIX := TimeZoneName[Timezone];
                //Necessary and in this order
                Err_TimeZone  := SetTimeZone(TzPOSIX);                          // WAIT API by OS!
                Err_LocalTime := SetLocalTime(NewLocTimeByNet);
            END_IF;
        {ENDREGION}
    {ENDREGION}
        
    {REGION BMS/FIELDBUS SERIAL PORTs CONFIGURATION}
//        CASE UoMZoneHMI OF            
//            UOM_ZONE#SI:
//                Supervisor.Info.Zone := SI;
//                // Server BMS uses only SI to communicate (Client FielBus <-> Server BMS)
//                // NOTE: In a net CLIENT+SERVER set NoConverion =0 beetwen: Client FielBus <-> Server BMS to increase pCO speed
//                // i.e.: FBnet.Info.Zone=0 and BMSnet.Info.Zone=0
//            UOM_ZONE#Imperial:
//                Supervisor.Info.Zone := Imperial;      
//        ELSE
//            Supervisor.Info.Zone := NONE;
//        END_CASE; 
    
        {REGION CHANGE BMS2 SETTINGS}
            {REGION PROCEDURE TO RESTORE BMS2 SETTINGS} 
                (*Memory after deleting command is immediately ready the next cycles*)
                IF ClientDeletingMem THEN
                    // Restore BMS2 settings                    
                    BMS2_Addr := BMS2_Addr_SavedRAM;
                    BMS2_Baud := BMS2_Baud_SavedRAM; 
                    BMS2_Conf := BMS2_Conf_SavedRAM;
                    
                    // Force update BMS2 settings
                    Bms2_ChangeSet := TRUE;
                END_IF;
            {ENDREGION}
          
            IF Bms2_ChangeSet THEN
                Bms2_ChangeSet := FALSE;
//                  SetupSerialSettings(Line_cPCOe2.SerialSettings, BMS2_Baud, BMS2_Conf);       
//                SetupSerialSettings(Supervisor.SerialSettings, BMS2_Baud, BMS2_Conf);
                
                // Change BMS address
//                Supervisor.ChangeIdent(BMS2_Addr);
                
                // Change setting of BMS supervisor port
//                Supervisor.ChangeSettings();
                
                // Set the same settings for BMS port on Default app (NOTE: In case of FW ugrade the device will be reachable with the previous settings)
//                SaveIdePortSettings(Supervisor.SerialSettings.Channel, Supervisor.SerialSettings.Speed, Supervisor.SerialSettings.Bits, Supervisor.SerialSettings.Parity, Supervisor.SerialSettings.Stops, BMS1_Addr);  
            END_IF;
        
//            BMS2_Online := Supervisor.Info.Online OR Dbg_BMS2Online;
        {ENDREGION}

        {REGION CHANGE FIELDBUS2 SETTINGS}
//            IF FB2_ChangeSet THEN
//                FB2_ChangeSet := FALSE;
                
//                SetupSerialSettings(MBM_Line.SerialSettings, FB2_Baud, FB2_Conf);
                
//                // Change setting of FB supervisor port
//                MBM_Line.ChangeSettings();
//            END_IF;            
        {ENDREGION}
    {ENDREGION}
            
    {REGION READ BUFFER OF EACH SERIAL PORT}
        // NOTE: when the protocols are in START the read() method obtain the variables
        //       from each buffer -> so the variables can be used inside STone.
        
        // BMS
//        Supervisor.Read();
        // Fieldbus
//        MBM_Line.Read();
    {ENDREGION}
    
    //------ CALL OF PROGRAMs ---------
    IF NOT ClientDeletingMem THEN
        Prg_ProgramsExecutor();
    END_IF;    
    //---------------------------------
    
    {REGION WRITE BUFFER OF EACH SERIAL PORT}
        IF ClientDeletingMem THEN
            //Stop all protocols.
//            Supervisor.Stop();
//            MBM_Line.Stop();
        ELSE
            {REGION BMS: WRITE VARIABLES}
                //Modbus Server line      
//                Supervisor.Write();
                //START COMMUNICATION
//                Supervisor.Start();
            {ENDREGION}
            
            {REGION FIELDBUS: WRITE VARIABLES}
                //Modbus Client line
//                MBM_Line.Write();
                //START COMMUNICATION
//                MBM_Line.Start();
            {ENDREGION}
        END_IF;        
    {ENDREGION}
    
    
	(* Refresh UI *)
	SendVirtualKey(NO_KEY, 1);
    
    //------------------------------------------------------------------------------------
    //------------ WARM SOFTWARE RESET----------------------------------------------------
    //------------------------------------------------------------------------------------ 
    TON_WaitRestartPlc(IN := ClientDeletingMem, PT := T#6s);
    IF TON_WaitRestartPlc.Q THEN 
        // Wait 6s because Retain will be write every 5s   
        // 0 - WARM start;
        SoftwareReset(0);
    END_IF;
END_PROGRAM