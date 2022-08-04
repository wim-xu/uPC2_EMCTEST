USING System;
USING System.UI;

FUNCTION ChangeDateFormatENTER
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
	VAR_IN_OUT
		value:USINT;
	END_VAR
    
    VAR
        MyDateFrmt : DateFormat;
    END_VAR
    
    MyDateFrmt := TO_USINT(value);
        
    GetDate_From_DateFormat(MyDateFrmt, LocDateAndTime, DateTimeBypGD1.Hour, DateTimeBypGD1.Minute, DateTimeBypGD1.Second, DateP1, DateP1Lmin, DateP1Lmax, DateP2, DateP2Lmin, DateP2Lmax, DateP3, DateP3Lmin, DateP3Lmax);
    
    pGD1.GoToNextField();

END_FUNCTION
