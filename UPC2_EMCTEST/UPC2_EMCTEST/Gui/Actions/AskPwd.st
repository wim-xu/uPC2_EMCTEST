USING System;
USING System.UI;

(**Ask password when pressed PRG key*)
FUNCTION AskPwd
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
    
    {REGION CHECK IF USER IS LOGGED}            
        Req_FixLED_PRG := TRUE;
    
        // Reset
        TmpPwd_Dig1 := 0;
        TmpPwd_Dig2 := 0;
        TmpPwd_Dig3 := 0;
        TmpPwd_Dig4 := 0;
        
        TmpPwd  := 0;
        
       // pGD1.MenuWidget.ResetWidget();
        MenuWidget1.ResetWidget();
        
        (*Check LogIn password, and if necessary asks to insert password*) 
        IF Access_User OR Access_Service OR Access_Manuf OR Access_Sys THEN
            pGD1.GoToLoop(pGD1_LoopList#Menu);
        ELSE
            WrngPwd := FALSE;
            pGD1.GoToLoop(pGD1_LoopList#Login);
        END_IF;
    {ENDREGION}

END_FUNCTION
