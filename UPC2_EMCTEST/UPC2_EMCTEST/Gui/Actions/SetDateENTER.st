USING System;
USING System.UI;

FUNCTION SetDateENTER
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
    VAR_IN_OUT
		value:UINT;
	END_VAR    
    
    SetDate_From_DateFormat(DateFrmt, DateTimeBypGD1.Hour, DateTimeBypGD1.Minute, DateTimeBypGD1.Second, DateP1, DateP2, DateP3); 
    
    pGD1.GoToNextField();
END_FUNCTION
