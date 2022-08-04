USING System;
USING System.UI;

FUNCTION GoToMainLoop
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
    
    Req_FixLED_PRG := FALSE;
    pGD1.GoToLoop(pGD1_LoopList#Main);
END_FUNCTION
