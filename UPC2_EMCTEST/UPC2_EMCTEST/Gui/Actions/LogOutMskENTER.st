USING System;
USING System.UI;

FUNCTION LogOutMskENTER
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
    
    {REGION RESET ACCESS}
        Access_Sys      := FALSE;
        Access_User     := FALSE;
        Access_Service := FALSE;
        Access_Manuf    := FALSE;
    {ENDREGION}
    
    MenuWidget1.ResetWidget();
    pGD1.GoToLoop(pGD1_LoopList#Main);
END_FUNCTION
