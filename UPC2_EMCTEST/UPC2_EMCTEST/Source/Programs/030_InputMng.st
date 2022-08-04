USING System;
USING System.IO;

USING Libs.AinMng_v2_0_1;

VAR_GLOBAL PERSISTENT
    (**Offeset of Ain1 probe*) {METADATA MIN_VAL -99.9}  {METADATA MAX_VAL 99.9}
    Ain1PrbOffset: REAL;
    (**Din1 relè logic. Logic to manage an ALARM (FALSE=NC, TRUE=NO).*)
    Din1Logic : BOOL := DIN_LOGIC_NC;
    (**Din2 relè logic. Logic to manage a COMMAND (FALSE=NC, TRUE=NO).*)
    Din2Logic : BOOL := DIN_LOGIC_NO;
END_VAR


PROGRAM InputMng
    VAR PUBLIC
        (**Din1 value (used as Remote unit alarm)*)
        Din1    : BOOL;
        (**Din2 value (used as Remote OnOff unit)*)
        Din2    : BOOL;
        (**Ain1 value*) {ATTRIBUTE UOM CELSIUS} {METADATA MIN_VAL -99.9} {METADATA MAX_VAL 99.9}
        Ain1Val : REAL;
    END_VAR
    VAR
        (**AinMng function block*)
        Ain1  : AinMng;        
    END_VAR 
    
    {REGION Din1: Unit remote alarm}
        Din1 := ID[1] XOR Din1Logic;
    {ENDREGION}
    
    {REGION Din2: Unit ON/OFF command}
        Din2 := ID[2] XOR Din2Logic;    
    {ENDREGION}
    
    {REGION Ain1: NTC probe}
        uConfig[1].mode_sel  := LIB_IO_AIN;                 (*Configuration of Ain1 as AIN*)
        uConfig[1].mode_type := LIB_IO_PROBE_NTC;           (*Configuration of Ain1 probe as NTC*)
        uConfig[1].filter    := PRB_FILTER;
        
        Ain1(
                Ain       := U[1].r,
                AinType   := uConfig[1].mode_sel,
                PrbOffset := Ain1PrbOffset,
              //MinVal    := REAL,
              //MaxVal    := REAL,
                AlrmDT    := PrbDly,
            
                En_FB     := TRUE,
            
                PrbVal    => Ain1Val
              //OnOffVal  => BOOL
              //PrbAlrm   =>... 
            );
        Alarms.Table.Al_Ain1Alrm.Info.Trigger := Ain1.PrbAlrm; // NOTE: is possible check -> (uConfig[1].error <> LIB_IO_NO_ERR)
    {ENDREGION}
    
END_PROGRAM