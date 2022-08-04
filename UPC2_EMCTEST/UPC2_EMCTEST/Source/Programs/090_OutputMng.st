USING System;
USING System.IO;

VAR_GLOBAL PERSISTENT
    (**Dout1 relè logic (FALSE=NO, TRUE=NC)*)
    Dout1Logic : BOOL := DOUT_LOGIC_NO;    
END_VAR

PROGRAM OutputMng
    VAR PUBLIC        
        (**Analog output 1 status*) {METADATA MIN_VAL 0.0} {METADATA MAX_VAL 100.0} {ATTRIBUTE UOM PERCENT}
        AOut1       : REAL;
    END_VAR
        
    {REGION DOut1}
        noConfig[1].enable    := TRUE;
        noConfig[1].mode_type := LIB_IO_STANDARD_RELE;
        //NO[1]                 := GblAlarm XOR Dout1Logic;
    {ENDREGION}    
    
    {REGION AOut1}
        yConfig[1].mode_type := LIB_IO_OUT_0_10V;
        //Y[1]                 := TO_UINT(AOut1 * 10.0);
    {ENDREGION}
END_PROGRAM
