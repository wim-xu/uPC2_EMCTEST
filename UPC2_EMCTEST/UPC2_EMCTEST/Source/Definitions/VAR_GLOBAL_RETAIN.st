(*----------------------------------
    ADD HERE YOUR RETAIN VARS!
----------------------------------*)

VAR_GLOBAL RETAIN
	(**UnSt - Unit ON/OFF command by keyboard (0=OFF 1=ON)*)
	KeybOnOff                   : BOOL := FALSE;
    (**Debug Force Product Code*)
    Dbg_ForceProductCode        : BOOL;
    (**Debug force BMS2 online*)
    Dbg_BMS2Online               : BOOL;
END_VAR