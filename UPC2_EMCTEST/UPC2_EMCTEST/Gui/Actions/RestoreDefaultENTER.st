USING System;
USING System.UI;

FUNCTION RestoreDefaultENTER
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
	VAR_IN_OUT
		value:BOOL;
	END_VAR

    pGD1.GoToNextField();
    IF value THEN
        pGD1.GoToLoop(pGD1_LoopList#DefaultDone);    
    END_IF;

END_FUNCTION
