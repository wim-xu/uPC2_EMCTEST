USING System;
USING System.Timer;
(*----------------------------------
         ADD HERE YOUR VARS!
----------------------------------*)
VAR_GLOBAL
    (**Restore application to defualt settings (FALSE=Disabled, TRUE=Enabled)*)
	Restoredefault   : BOOL;	
    (**Instance to manage comunication between Client&Salve in Modbus client protocol with Fieldbus port*)
//    ClientModbus_pCO : MBM_Template_pCO;	
    
    {REGION SYSTEM INFO}
        (**Retain writings number*)
        RetainWrN       : UDINT;
        (**Task Main live counter*)
        TaskMainLiveCnt : UINT;
        (**Task Main execution time*)
        {ATTRIBUTE UOM MILLISECOND}
        TaskMainExeT    : UDINT;    
        (**Current System Time*)
        {ATTRIBUTE UOM MILLISECOND}
        CurrSysT        : UDINT;        
        (**Task Main current execution time*)
        {ATTRIBUTE UOM MILLISECOND}
        TaskMainCurrT   : UDINT;
    
        (**System Info structure*)
        SysInfo         : SystemInfo;
        (**Hardware Info structure*)
        HardwareInfo    : HardwareDescription;
        (**Prject information*)
        InfoProject     : ProjectInfo;
        (**Product information read in OTP memory*)
        InfoProduct     : ProductInfo;  
    
        (**PLC SW can GO*)
        Go_PLC          : BOOL;
    
        (**Device model*)
		DeviceType      : UINT;
        (**Board type*)
        BoardType       : UINT;
        (**Target machine type*)
		MachineType     : UINT;
        (**Target hardware code*)
		HwCode          : UINT;
    
        RetainMemWrites : ULINT;
        
        (**Stone project GUID*)
        GUID : StonePrjGUID;
    {ENDREGION}  
    
    {REGION Used by APPLICA to manage clock and timeZONE}
        APPsCfgRTC : APPsConfigRTC;
    {ENDREGION}
    
    {REGION HMI}
        (**Logged in pGD1 display as Service*)
    	Access_Service : BOOL;
        (**Logged in pGD1 display as User*)
    	Access_User    : BOOL;
        (**Logged in pGD1 display as Manufacturer*)
    	Access_Manuf   : BOOL;
        (**Logged in pGD1 display as System Manager*)
    	Access_Sys     : BOOL;
        (**Switch to TRUE or FALSE every second*)
        Blink          : BOOL;
        (**Password used for Loging procedure (User, Service, Manufacturer, System)*) {METADATA MIN_VAL 0} {METADATA MAX_VAL 3}
        LoginPwdType   : USINT;
    
    	{REGION Management of "Date and Hour" displayed by pGD1 display}
            (**Current local time (read only)*)
            CurrLocTime    : DateTimeRTC;
            (**UTC Date and Time*)
            TimeUTC        : DATE_AND_TIME;
            (**Local Date and Time based on current time zone*)
            LocDateAndTime : DATE_AND_TIME;
            (**Local time based on current time zone*)
            LocTime        : DateTime;
            (**Current day of week*)
            Day_Week       : DayOfWeek(0..6);
            (**Set clock settings by Net*)
            SetClockByNet  : BOOL;
        {ENDREGION}
    
        {REGION Date and time changing management by Network}
            (**Values of Date and Time used to modify RTC by network*)
            NewDateTimeByNet  : DateTimeRTC;  
        {ENDREGION}          
    
        {REGION Date and time changing management by pGD1}
            (**Values of Date and Time used to modify clock by pGD1*)
            DateTimeBypGD1 : TimeRTC;
    
            (**Date element position P1, the date format is P1/P2/P3*) {METADATA MIN_VAL DateP1Lmin} {METADATA MAX_VAL DateP1Lmax}            
            DateP1     : DatePosRange;
            (**Date element position P1 limit min*)
            DateP1Lmin : DatePosRange;
            (**Date element position P1 limit max*)
            DateP1Lmax : DatePosRange;
            
            (**Date element position P2, the date format is P1/P2/P3*) {METADATA MIN_VAL DateP2Lmin} {METADATA MAX_VAL DateP2Lmax}
            DateP2     : DatePosRange;
            (**Date element position P2 limit min*)
            DateP2Lmin : DatePosRange;
            (**Date element position P2 limit max*)
            DateP2Lmax : DatePosRange;
    
            (**Date element position P3, the date format is P1/P2/P3*) {METADATA MIN_VAL DateP3Lmin} {METADATA MAX_VAL DateP3Lmax}
            DateP3     : DatePosRange;
            (**Date element position P3 limit min*)
            DateP3Lmin : DatePosRange;
            (**Date element position P3 limit max*)
            DateP3Lmax : DatePosRange;
        {ENDREGION}
    {ENDREGION}
    
    {REGION ALARMS MANAGEMENT BY HMI}
        (**Some alarms have been triggered by system. It's necessary to reset them*)
	    GblAlarm            : BOOL;
        (**Buzzer status (FALSE=Active, TRUE=Silenced)*)
	    BuzzerSilenced      : BOOL := FALSE;
        (**Requet to make blink LED-Alarm*)
        Req_BlinkLED_Alarm  : BOOL;
        (**Requet to maintain LED-Alarm's light on and fixed)*)
        Req_FixLED_Alarm    : BOOL;
        (**Requet TO make blink LED-PRG*)
        Req_BlinkLED_PRG    : BOOL;
        (**Requet to maintain LED-PRG's light on and fixed)*)
        Req_FixLED_PRG      : BOOL;
    {ENDREGION}
    
        //New add variable because of buliting error
        MenuWidget1 : MenuWidget;
        SubMenuWidget1 : SubMenuWidget;
        HistoryAlarmsWidget1 : HistoryAlarmsWidget;
        
    
    {REGION Management of HMI LEDs}
        (**Mng. of LED blinking Alarm*)
    	DisplayBlinkLED_Alarm      : BOOL;
        (**Mng. of LED Alarm*)
    	DisplayLED_Alarm           : BOOL;    
        (**Mng. of LED blinking PRG*)
    	DisplayBlinkLED_PRG        : BOOL;
        (**Mng. of LED PRG*)
    	DisplayLED_PRG             : BOOL;
        (**Mng. of LED blinking BACKGROUND*)
    	DisplayBlinkLED_BACKGROUND : BOOL;
        (**Mng. of LED BACKGROUND*)
        DisplayLED_BACKGROUND      : BOOL;
    {ENDREGION}
    
    
    {REGION Unit management}
        (**Unit ON/OFF status (FALSE=ON, TRUE=OFF)*)
    	UnitOff         : BOOL;    
    	(**Unit ON/OFF status (FALSE=OFF, TRUE=ON)*)
    	UnitOn          : BOOL;    
        (**Unit ON/OFF command by Scheduler (FALSE=On, TRUE=Off)*)
    	SchedOnOff      : BOOL; 
    {ENDREGION}
    
    {REGION Main Mask}  
    	(**UnitStatus - Unit status*)
    	UnitStatus      : UNIT_STATUS (UNIT_STATUS#NOT_Used..UNIT_STATUS#Purging);
        (**Index of the Quick Menu*)
        IdxQM           : QUICK_MENU (QUICK_MENU#OnOff..QUICK_MENU#Info);
        (**Index of the image displayed by Quick Menu*)
        IdxImgQM        : USINT (0..5);
    {ENDREGION}
    
    {REGION Managemnet of Password in pGD1 interface}
        (**Temporary password*)
    	TmpPwd      : UINT(0..9999) := 0;
    	(**Temporary password digit 1*)
    	TmpPwd_Dig1 : UINT(0..9) := 0;
    	(**Temporary password digit 2*)
    	TmpPwd_Dig2 : UINT(0..9) := 0;
    	(**Temporary password digit 3*)
    	TmpPwd_Dig3 : UINT(0..9) := 0;
    	(**Temporary password digit 4*)
    	TmpPwd_Dig4 : UINT(0..9) := 0;
    {ENDREGION}
    
    {REGION LANGUAGE MASK MANAGEMENT}
        (**Language string displayed inside LanguageSelection mask*)
        LangMskStr : STRING;
        (**Language acronym displayed inside LanguageSelection mask*)
        LangMskAcr : STRING;
    {ENDREGION}
    
    {REGION BMS1 management}
        (**Applies the settings of serial line BMS1 (Auto-Reset excuted by application)*)
        BMS1_ChangeSet   : BOOL := TRUE; 
    {ENDREGION}
    
    {REGION BMS2 management}        
        (**Applies the settings of serial line BMS2 (Auto-Reset excuted by application)*)
        BMS2_ChangeSet   : BOOL := TRUE;    
        (**BMS2 net online (a client is quering on BMS net this board)*)
    	BMS2_Online      : BOOL;    	
        
        {REGION Used to save BMS2 settings}
            BMS2_Addr_SavedRAM : USINT(1..247);
        	BMS2_Baud_SavedRAM : Serial_Speed;
        	BMS2_Conf_SavedRAM : Serial_ParityStopBits;    
        {ENDREGION}
    
    	(**Unit On/Off command by NET (0=OFF, 1=ON)*)
    	NET_OnOff : BOOL;
    {ENDREGION}    
    
    {REGION FIELDBUS1 MANAGEMENT}
        (**Applies the settings of serial line FB1 (Auto-Reset excuted by application)*)
        FB1_ChangeSet : BOOL := TRUE; 
    {ENDREGION}
    
    {REGION FIELDBUS2 MANAGEMENT}
        (**Applies the settings of serial line FB2 (Auto-Reset excuted by application)*)
        FB2_ChangeSet : BOOL := TRUE;      
    {ENDREGION}
    
    {REGION Unit On}
        (**Reset of all hours counter (FALSE=None, TRUE=Reset)*)
        ResTotCnt    : BOOL;
        (**Unit On hours counter*) {ATTRIBUTE UOM HOUR}
        UnitOnHrs    : UDINT;
        (**Unit On reset hour counters*)
    	UnitOnResHrs : BOOL;
    {ENDREGION}
    
    {REGION BLACKOUT} 
        (**Date of the last power off expressed in seconds (Unix Timestamp, seconds from January 1st 1970)*)
        PwrOffDate_NVRAM_BLKO : UDINT; 
        (**Duration of the power off in minutes*)   {METADATA MIN_VAL 0} {METADATA MAX_VAL 59} {ATTRIBUTE UOM MINUTE}
        OffMins_BLKO       :UINT;                                       
        (**Duration of the power off in hours*)     {METADATA MIN_VAL 0} {METADATA MAX_VAL 23} {ATTRIBUTE UOM HOUR}
        OffHours_BLKO      :UINT;
        (**Duration of the power off in days*)      {METADATA MIN_VAL 1} {METADATA MAX_VAL 999} {ATTRIBUTE UOM DAY}
        OffDays_BLKO       :UINT;                                      
        (**Last second in which Plc was on*)        {METADATA MIN_VAL 0} {METADATA MAX_VAL 59} {ATTRIBUTE UOM SECOND}
        LastOnSec_BLKO     :UINT;   
        (**Last minute in which Plc was on*)        {METADATA MIN_VAL 0} {METADATA MAX_VAL 59} {ATTRIBUTE UOM MINUTE}
        LastOnMin_BLKO     :UINT;    
        (**Last hour in which Plc was on*)          {METADATA MIN_VAL 0} {METADATA MAX_VAL 23} {ATTRIBUTE UOM HOUR}
        LastOnHour_BLKO    :UINT; 
        (**Last day in which Plc was on*)           {METADATA MIN_VAL 1} {METADATA MAX_VAL 31} {ATTRIBUTE UOM DAY}
        LastOnDay_BLKO     :UINT;  
        (**Last month in which Plc was on*)         {METADATA MIN_VAL 1} {METADATA MAX_VAL 12} {ATTRIBUTE UOM MONTH}
        LastOnMonth_BLKO   :UINT;   
        (**Last year in which Plc was on*)          {METADATA MIN_VAL 2021} {METADATA MAX_VAL 2200} {ATTRIBUTE UOM YEAR}
        LastOnYear_BLKO    :UINT;
    {ENDREGION}
    
END_VAR