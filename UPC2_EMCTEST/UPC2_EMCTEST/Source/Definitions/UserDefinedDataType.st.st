(*----------------------------------
         ADD HERE YOUR TYPES!
----------------------------------*)
TYPE
    (**STone project GIUD*)
    StonePrjGUID:
        STRUCT
            Grp1 : STRING[8];
            Grp2 : STRING[4];
            Grp3 : STRING[4];
            Grp4 : STRING[4];
            Grp5 : STRING[12];        
        END_STRUCT;
    
    (**Date position range*)
    DatePosRange : UINT(0..99);
    
    (**Time Struct used to change RTC*)
    TimeRTC: STRUCT
        (**Hourh*)  {ATTRIBUTE UOM HOUR}
        Hour        : UINT(0..23);
        (**Minute*) {ATTRIBUTE UOM MINUTE}
        Minute      : UINT(0..59);
        (**Second*){ATTRIBUTE UOM SECOND}
        Second      : UINT(0..59);
        (**Millisecond*){ATTRIBUTE UOM MILLISECOND}
        Millisecond : UINT(0..999);
    END_STRUCT;
    
    (**Date Struct used to change RTC*)
    DateRTC: STRUCT
        (**Day*)    {ATTRIBUTE UOM DAY}
        Day         : UINT(1..31);
        (**Month*)  {ATTRIBUTE UOM MONTH}
        Month       : UINT(1..12);
        (**Year*)   {ATTRIBUTE UOM YEAR}
        Year        : UINT(2021..2200);
    END_STRUCT;
    
    (**Date and time Struct used to change RTC*)
    DateTimeRTC: STRUCT
        (**Day*)    {ATTRIBUTE UOM DAY}
        Day         : UINT(1..31);
        (**Month*)  {ATTRIBUTE UOM MONTH}
        Month       : UINT(1..12);
        (**Year*)   {ATTRIBUTE UOM YEAR}
        Year        : UINT(2021..2200);
        (**Hourh*)  {ATTRIBUTE UOM HOUR}
        Hour        : UINT(0..23);
        (**Minute*) {ATTRIBUTE UOM MINUTE}
        Minute      : UINT(0..59);
        (**Second*){ATTRIBUTE UOM SECOND}
        Second      : UINT(0..59);
        (**Millisecond*){ATTRIBUTE UOM MILLISECOND}
        Millisecond : UINT(0..999);
    END_STRUCT;
    
       
    (**Units measure zone*)
    UOM_ZONE :
        (
        (**No Zone*)
        NONE,
        (**International System Zone [°C/bar]*)
        SI,
        (**Imperial Zone [°F/psi]*)
        Imperial
        );

   (**Unit status type*)
    UNIT_STATUS:
    (
        NOT_Used,                   (**Bacnet compatibility*)
        UnitON,                     (**Unit ON*)   
        OffByAlarm,                 (**Off By Alarm*)         
        OffByBMS,                   (**Off By BMS*)
        OffByScheduler,             (**Off By Scheduler*)
        OffByDI,                    (**Off By Digital Input*)
        OffByKeyboard,              (**Off By Keyboard*)
        OffByNetwork,               (**Off By Network*)
        Manual,                     (**Unit manual mode active*)
        ChangeOver,                 (**ChangeOver*)
        SwitchON,                   (**Switch ON*)
        ShutDown,                   (**Shut Down*)
        PreConditioning,            (**Pre-Conditioning*)
        Dehumidification,           (**Dehumidification*)
        Antifreeze,                 (**Antifreeze*)
        Defrost,                    (**Defrost*)
        AirPressure_Flow,           (**Air Pressure/Flow*)
        AirQuality,                 (**Air Quality*)
        Cooling,                    (**Cooling*)
        Heating,                    (**Heating*)
        FreeCooling,                (**FreeCooling*)
        FreeHeating,                (**FreeHeating*)
        LowTemperatureControl,      (**Low Temperature Control*)
        HighTemperatureControl,     (**High Temperature Control*)
        TestIO,                     (**Test I/O*)
        DHW,                        (**Domestic Hot Water*)
        InactivityStart,            (**Inactivity Start*)
        HighSaturationHumidity,     (**High Saturation Humidity*)
        Purging                     (**Purging*)
    ); 
    
    (**List of Quick Menu position*)
    QUICK_MENU:
    (
        (**Selected Loop OnOff*)
        OnOff,
        (**Selcted Loop Set*)
        Set,
        (**Selected Loop Info*)
        Info
    );
    
    (**Current state of HMI - Used to manage LogoMask/LanguageMask/MainMask transition*)
    State_HMI:
    (
        Wait,
        DisplayLogoMask,
        DisplayLanguageMask,
        DisplayMainMask
    );
    
    (**Serial port configuration (Parity and Stop bits)*)
    Serial_ParityStopBits :
    (
        (**NONE-1*)
        NONE_1,
        (**NONE-2*)
        NONE_2,    
        (**EVEN-1*)
        EVEN_1,
        (**EVEN-2*)
        EVEN_2,
        (**ODD-1*)
        ODD_1,
        (**ODD-2*)
        ODD_2
    );
    
    (**Serial port baud rate configuration*)
    Serial_Speed :
    (
        (**Baud rate 1200*)
        Baud_1200,
        (**Baud rate 2400*)
        Baud_2400,
        (**Baud rate 4800*)
        Baud_4800,
        (**Baud rate 9600*)
        Baud_9600,
        (**Baud rate 19200*)
        Baud_19200,
        (**Baud rate 38400*)
        Baud_38400,
        (**Baud rate 57600*)
        Baud_57600,
        (**Baud rate 115200*)
        Baud_115200,
        (**Baud rate 375000*)
        Baud_375000
    );
    
    (**Type of password used for Login procedure*)
    LOGIN_PASSWORD : 
    (
        User,
        Service,
        Manufacturer,
        System   
    );
    
    (**Used by APPLICA to manage clock and timezone*)
    APPsConfigRTC: 
        STRUCT            
        	(**Every time it's value change the PLC change it's RTC*)
        	SetRTC     : BOOL;
            (**New "Date and Time" used to update the RTC*)
        	DateTime   : DATE_AND_TIME;
        	(**New "Time Zone" used to update the RTC*)
        	TimeZone   : STRING;    
        END_STRUCT;

END_TYPE

