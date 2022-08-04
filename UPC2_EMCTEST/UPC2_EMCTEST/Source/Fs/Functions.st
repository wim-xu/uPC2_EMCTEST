USING System;
USING System.Text;
USING System.Timer;
USING System.Serial;

(** Allow to setup settings for a serial line. *)
FUNCTION SetupSerialSettings
    VAR_IN_OUT
        (** Serial settings *)
        Settings : SerialSettings;
    END_VAR
    VAR_INPUT
        (** Serial speed (Baudrate) *)
        Speed    : Serial_Speed;
        (** Serial parity stop bits *)
        StopBit  : Serial_ParityStopBits;
    END_VAR
    
    // Change of serial baudrate
    CASE Speed OF
        Serial_Speed#Baud_1200:   Settings.Speed := 1200;
        Serial_Speed#Baud_2400:   Settings.Speed := 2400;
        Serial_Speed#Baud_4800:   Settings.Speed := 4800;
        Serial_Speed#Baud_9600:   Settings.Speed := 9600;
        Serial_Speed#Baud_19200:  Settings.Speed := 19200;
        Serial_Speed#Baud_38400:  Settings.Speed := 38400;
        Serial_Speed#Baud_57600:  Settings.Speed := 57600;
        Serial_Speed#Baud_115200: Settings.Speed := 115200;
        Serial_Speed#Baud_375000: Settings.Speed := 375000; 
    END_CASE;
    
    // Change of serial settings
    CASE StopBit OF
        // 8-NONE-1
        Serial_ParityStopBits#NONE_1:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#None;
            Settings.Stops  := SERIAL_STOP_1;                
        
        // 8-NONE-2
        Serial_ParityStopBits#NONE_2:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#None;
            Settings.Stops  := SERIAL_STOP_2;                
        
        // 8-EVEN-1
        Serial_ParityStopBits#EVEN_1:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Even;
            Settings.Stops  := SERIAL_STOP_1;                
        
        // 8-EVEN-2
        Serial_ParityStopBits#EVEN_2:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Even;
            Settings.Stops  := SERIAL_STOP_2;                
        
        // 8-ODD-1
        Serial_ParityStopBits#ODD_1:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Odd;
            Settings.Stops  := SERIAL_STOP_1;                
        
        // 8-ODD-2
        Serial_ParityStopBits#ODD_2:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Odd;
            Settings.Stops  := SERIAL_STOP_2;                
    END_CASE;
END_FUNCTION

(**Gets date from the date fromat selected.*)
FUNCTION GetDate_From_DateFormat
    VAR_IN_OUT CONSTANT
        (**Date format enum. set by DateTimeChg mask (0=DD/MM/YYYY, 1=MM/DD/YYYY, 2=YYYY/MM/DD)*)
        DateFrmt       : DateFormat;
        (**Local Date and Time*)
        LocDateAndTime : DATE_AND_TIME;
    END_VAR
    VAR_IN_OUT
        (**Hours*)
        {ATTRIBUTE UOM HOUR}
        hh : UINT(0..23);
        (**Minutes*)
        {ATTRIBUTE UOM MINUTE}
        mn : UINT(0..59);
        (**Seconds*)
        {ATTRIBUTE UOM SECOND}
        ss : UINT(0..59);
        (**Date element position P1, the date format is P1/P2/P3*)
        DateP1     : DatePosRange;
        (**Date element position P1 limit min*)
        DateP1Lmin : DatePosRange;
        (**Date element position P1 limit max*)
        DateP1Lmax : DatePosRange;
        
        (**Date element position P2, the date format is P1/P2/P3*)
        DateP2     : DatePosRange;
        (**Date element position P2 limit min*)
        DateP2Lmin : DatePosRange;
        (**Date element position P2 limit max*)
        DateP2Lmax : DatePosRange;

        (**Date element position P3, the date format is P1/P2/P3*)
        DateP3     : DatePosRange;
        (**Date element position P3 limit min*)
        DateP3Lmin : DatePosRange;
        (**Date element position P3 limit max*)
        DateP3Lmax : DatePosRange;
    END_VAR
    VAR
        (** The date time info. *)
        LocDateTime : DateTime;
    END_VAR
    
    SPLIT_DT(LocDateAndTime, LocDateTime);
    
    hh := LocDateTime.Hour;
    mn := LocDateTime.Minute;
    ss := LocDateTime.Second;    
    
    IF LocDateTime.Year <2021 THEN
        LocDateTime.Year := 21;
    ELSE
        LocDateTime.Year := LocDateTime.Year - 2000;
    END_IF;        
        
    (*Align date visibility with the current date format*)
    CASE DateFrmt OF
        DateFormat#DDMMYYYY: 
            DateP1     := LocDateTime.Day;
            DateP1Lmin := 1;
            DateP1Lmax := 31;
        
            DateP2     := LocDateTime.Month;
            DateP2Lmin := 1;
            DateP2Lmax := 12;
        
            DateP3     := LocDateTime.Year;
            DateP3Lmin := 0;
            DateP3Lmax := 99;
        
        DateFormat#MMDDYYYY:
            DateP1     := LocDateTime.Month;
            DateP1Lmin := 1;
            DateP1Lmax := 12;
        
            DateP2     := LocDateTime.Day;
            DateP2Lmin := 1;
            DateP2Lmax := 31;
        
            DateP3     := LocDateTime.Year;
            DateP3Lmin := 0;
            DateP3Lmax := 99;
        
        DateFormat#YYYYMMDD:
            DateP1     := LocDateTime.Year;
            DateP1Lmin := 0;
            DateP1Lmax := 99;
        
            DateP2     := LocDateTime.Month;
            DateP2Lmin := 1;
            DateP2Lmax := 12;
        
            DateP3     := LocDateTime.Day;
            DateP3Lmin := 1;
            DateP3Lmax := 31;        
    END_CASE;
END_FUNCTION

(** Returns 0 IF operation successful; error code otherwise. *)
FUNCTION SetDate_From_DateFormat : UINT
    VAR_IN_OUT CONSTANT
        (**Date format enum. set by DateTimeChg mask (0=DD/MM/YYYY, 1=MM/DD/YYYY, 2=YYYY/MM/DD)*)
        DateFrmt: DateFormat;
        (**Hours*)
        {ATTRIBUTE UOM HOUR}
        hh      : UINT(0..23);
        (**Minutes*)
        {ATTRIBUTE UOM MINUTE}
        mn      : UINT(0..59);
        (**Seconds*)
        {ATTRIBUTE UOM SECOND}
        ss      : UINT(0..59);
        (**Date element position P1, the date format is P1/P2/P3*)
        DateP1  : DatePosRange;
        (**Date element position P2, the date format is P1/P2/P3*)
        DateP2  : DatePosRange;
        (**Date element position P3, the date format is P1/P2/P3*)
        DateP3  : DatePosRange;
    END_VAR    
    VAR
        (** The date time info. *)
        LocDateTime : DateTime;
    END_VAR            
        
    LocDateTime.Hour   := hh;
    LocDateTime.Minute := mn;
    LocDateTime.Second := ss; 
    
    (*Align date visibility with the current date format*)
    CASE DateFrmt OF
        DateFormat#DDMMYYYY: 
            LocDateTime.Day   := DateP1;        
            LocDateTime.Month := DateP2;        
            LocDateTime.Year  := DateP3 + 2000;
        
        DateFormat#MMDDYYYY:
            LocDateTime.Month := DateP1;        
            LocDateTime.Day   := DateP2;        
            LocDateTime.Year  := DateP3 + 2000;
        
        DateFormat#YYYYMMDD:
            LocDateTime.Year  := DateP1 + 2000;        
            LocDateTime.Month := DateP2;        
            LocDateTime.Day   := DateP3;
    END_CASE;    
    
    SetDate_From_DateFormat := SetLocalTime(LocDateTime);
END_FUNCTION

(**Returns Stone project GUID splitted.*)
FUNCTION SplitPrjGUID : StonePrjGUID
    VAR_IN_OUT CONSTANT
        (**↓ Stone project GUID*)
        ProjectID : STRING;
    END_VAR
    SplitPrjGUID.Grp1 := MID(ProjectID,  8, 1);
    SplitPrjGUID.Grp2 := MID(ProjectID,  4, 0+8);
    SplitPrjGUID.Grp3 := MID(ProjectID,  4, 0+8+4);
    SplitPrjGUID.Grp4 := MID(ProjectID,  4, 0+8+4+4);
    SplitPrjGUID.Grp5 := MID(ProjectID, 12, 0+8+4+4+4);
END_FUNCTION