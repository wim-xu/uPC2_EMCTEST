USING System;
USING System.UI;

VAR_GLOBAL
    (**Saves current time*)
    {ATTRIBUTE UOM MILLISECOND}
    MemTimePwdWrg           : UDINT;
END_VAR


FUNCTION CheckPassword
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
	VAR_IN_OUT
		value:UINT;
	END_VAR
    
    (* Saves the last digit. *)
    pGD1.GoToNextField();
    
    WrngPwd := FALSE;
    (* Concatenate the digits to reconstruct the password. *)
    TmpPwd := TmpPwd_Dig1*1000 + TmpPwd_Dig2*100 + TmpPwd_Dig3*10 + TmpPwd_Dig4;
    
    IF TmpPwd = PwdSys THEN
        Access_Sys      := TRUE;
        LoginPwdType    := LOGIN_PASSWORD#System;
    ELSIF TmpPwd = PwdUser THEN
        Access_User     := TRUE;
        LoginPwdType    := LOGIN_PASSWORD#User;
    ELSIF TmpPwd = PwdService THEN
        Access_Service  := TRUE;
        LoginPwdType    := LOGIN_PASSWORD#Service;
    ELSIF TmpPwd = PwdManuf THEN
        Access_Manuf    := TRUE;
        LoginPwdType    := LOGIN_PASSWORD#Manufacturer;
    ELSE
        WrngPwd         := TRUE;
        MemTimePwdWrg   := CurrSysT;
    END_IF;


    IF Access_User OR Access_Service OR Access_Sys OR Access_Manuf THEN 
        pGD1.GoToLoop(pGD1_LoopList#Menu);
    ELSE
        (* Reset. *)
        TmpPwd_Dig1 := 0;
        TmpPwd_Dig2 := 0;
        TmpPwd_Dig3 := 0;
        TmpPwd_Dig4 := 0;
        
        TmpPwd  := 0;
        
        (* Repositions the cursor to the first digit. *)
        pGD1.GoToNextField();
    END_IF;

END_FUNCTION
