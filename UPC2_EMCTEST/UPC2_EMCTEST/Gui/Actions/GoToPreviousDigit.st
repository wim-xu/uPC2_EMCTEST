USING System;
USING System.UI;

FUNCTION GoToPreviousDigit
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR

    VAR
        i : INT;
    END_VAR
    
    FOR i := 1 TO 4 DO
        pGD1.GoToNextField();
    END_FOR;
END_FUNCTION
