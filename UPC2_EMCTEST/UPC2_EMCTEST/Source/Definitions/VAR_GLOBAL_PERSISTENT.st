(*----------------------------------
    ADD HERE YOUR VARS!
----------------------------------*)
VAR_GLOBAL PERSISTENT
    
    {REGION HMI}
        (**Return to main mask after 300 seconds*)
        {ATTRIBUTE UOM SECOND}
        ReturnMainMaskTime : UINT(0..9999) := 300;        
        (**Units measure zone used in HMI*)
    	UoMZoneHMI         : UOM_ZONE := UOM_ZONE#SI;        
        (**Date format enum. set by DateTimeChg mask (0=DD/MM/YYYY, 1=MM/DD/YYYY, 2=YYYY/MM/DD)*)
        DateFrmt           : DateFormat(DateFormat#DDMMYYYY..DateFormat#YYYYMMDD) := DateFormat#DDMMYYYY;    
        (**Timezone*) {METADATA MIN_VAL 1} {METADATA MAX_VAL 136}
        Timezone           : UINT(1..136) := 50;  (*50=ROME and POSIX is 'CET-1CEST,M3.5.0,M10.5.0/3'*)
    {ENDREGION}
    
    {REGION ALARMS MANAGEMENT BY HMI}
        (**Enable buzzer (FALSE=Disabled, TRUE=Enabled)*)
    	En_Buzzer : BOOL := TRUE;	
    {ENDREGION}

    {REGION LANGUAGE MANAGEMENT}
        (**Shows the language mask at the first SW start up to select language*)
        ShowMskLanguage   : BOOL := TRUE;
        (**Save language*)
        LanguageID      : UINT := 2;
    {ENDREGION}
    
    {REGION LOGIN MANAGEMENT}   
        (**System password*)        {METADATA MIN_VAL 0} {METADATA MAX_VAL 9999}
        PwdSys        : UINT (0..9999) := 1604;
        (**User password*)          {METADATA MIN_VAL 0} {METADATA MAX_VAL 9999}
        PwdUser       : UINT (0..9999) := 0000;
        (**Service password*)       {METADATA MIN_VAL 0} {METADATA MAX_VAL 9999}
        PwdService    : UINT (0..9999) := 1234;
        (**Manufacturer password*)  {METADATA MIN_VAL 0} {METADATA MAX_VAL 9999}
        PwdManuf      : UINT (0..9999) := 9999;
    {ENDREGION}
    
    {REGION Probes settings}
        (**SetP setpoint*)
    	{ATTRIBUTE UOM CELSIUS}
    	{METADATA MIN_VAL 15.0}
    	{METADATA MAX_VAL 25.0}
    	SetT : REAL := 15.0;
    {ENDREGION}
    
    {REGION BMS1/2 management}
        (**Enable unit ON/OFF command by BMS net (0=Disabled, 1=Enabled)*)
    	En_BmsOffOn : BOOL := FALSE;
        (**Unit On/Off command by BMS (0=OFF, 1=ON)*)
        BmsOffOn    : BOOL := FALSE;
    {ENDREGION}
    
    {REGION BMS1 settings}
        (**BMS port serial address*)
        {METADATA MIN_VAL 1} {METADATA MAX_VAL 247}
    	BMS1_Addr    : USINT(1..247) := 1;
    	(**BMS port baud rate (0=1200, 1=2400, 2=4800, 3=9600, 4=19200, 5=38400, 6=57600, 7=115200, 8=375000)*)
    	BMS1_Baud    : Serial_Speed (Serial_Speed#Baud_1200..Serial_Speed#Baud_375000):= Serial_Speed#Baud_19200;
    	(**BMS port network settings (0=NONE-1, 1=NONE-2, 2=EVEN-1, 3=EVEN-2, 4=ODD-1, 5=ODD-2)*)
    	BMS1_Conf    : Serial_ParityStopBits (Serial_ParityStopBits#NONE_1..Serial_ParityStopBits#ODD_2) := Serial_ParityStopBits#NONE_2;
    {ENDREGION}
    
    {REGION BMS2 settings}
        (**BMS2 port serial address*)
        {METADATA MIN_VAL 1} {METADATA MAX_VAL 247}
    	BMS2_Addr    : USINT(1..247) := 1;
    	(**BMS2 port baud rate (0=1200, 1=2400, 2=4800, 3=9600, 4=19200, 5=38400, 6=57600, 7=115200, 8=375000)*)
    	BMS2_Baud    : Serial_Speed (Serial_Speed#Baud_1200..Serial_Speed#Baud_375000):= Serial_Speed#Baud_19200;
    	(**BMS2 port network settings (0=NONE-1, 1=NONE-2, 2=EVEN-1, 3=EVEN-2, 4=ODD-1, 5=ODD-2)*)
    	BMS2_Conf    : Serial_ParityStopBits (Serial_ParityStopBits#NONE_1..Serial_ParityStopBits#ODD_2) := Serial_ParityStopBits#NONE_2;
    {ENDREGION}    
    
    {REGION FIELDBUS1 settings}
	    (**Enable Fieldbus1 protocol (0=Disabled, 1=Enabled)*)
	    En_FB1   : BOOL := FALSE;
    	(**FiledBus1 port baud rate (0=1200, 1=2400, 2=4800, 3=9600, 4=19200, 5=38400, 6=57600, 7=115200, 8=375000)*)
    	FB1_Baud : Serial_Speed (Serial_Speed#Baud_1200..Serial_Speed#Baud_375000):= Serial_Speed#Baud_19200;
    	(**FiledBus1 port network settings (0=NONE-1, 1=NONE-2, 2=EVEN-1, 3=EVEN-2, 4=ODD-1, 5=ODD-2)*)
    	FB1_Conf : Serial_ParityStopBits (Serial_ParityStopBits#NONE_1..Serial_ParityStopBits#ODD_2) := Serial_ParityStopBits#NONE_2;
    {ENDREGION}
    
    {REGION FIELDBUS2 settings}
	    (**Enable Fieldbus2 protocol (0=Disabled, 1=Enabled)*)
	    En_FB2   : BOOL := FALSE;
    	(**FiledBus2 port baud rate (0=1200, 1=2400, 2=4800, 3=9600, 4=19200, 5=38400, 6=57600, 7=115200, 8=375000)*)
    	FB2_Baud : Serial_Speed (Serial_Speed#Baud_1200..Serial_Speed#Baud_375000):= Serial_Speed#Baud_19200;
    	(**FiledBus2 port network settings (0=NONE-1, 1=NONE-2, 2=EVEN-1, 3=EVEN-2, 4=ODD-1, 5=ODD-2)*)
    	FB2_Conf : Serial_ParityStopBits (Serial_ParityStopBits#NONE_1..Serial_ParityStopBits#ODD_2) := Serial_ParityStopBits#NONE_2;
    {ENDREGION}
    
    {REGION ALARMS}
        (**U005- Alarm relay configuration (0=Regulation alarms, 1=All alarms)*)
    	AlarmRelayCfg : BOOL := FALSE;
        (**Enable status of remote alarm by Din (FALSE=Disabled, TRUE=Enabled)*)
        En_DinAlrm    : BOOL := FALSE;
    {ENDREGION}
    
    {REGION Unit On hours counter}
        (**Unit On working hours (partial)*)
    	{ATTRIBUTE UOM HOUR}
    	UnitOnHrsPartial : UDINT;
    	(**Unit On working hours (total)*)
    	{ATTRIBUTE UOM HOUR}
    	UnitOnHrsTot     : UDINT;
    {ENDREGION}
    
    {REGION On/Off by Din }
        (**Enable On/Off by Din*)
        En_DinOffOn : BOOL := FALSE;
    {ENDREGION}
END_VAR

