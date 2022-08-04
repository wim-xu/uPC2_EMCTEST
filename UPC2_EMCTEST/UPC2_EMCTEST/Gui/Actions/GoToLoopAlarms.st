USING System;
USING System.UI;

FUNCTION GoToLoopAlarms
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
    
//    IF NOT EnLangMskCdwnT THEN                          (*At the 1st SW start up the LANGUAGE Mask has Key-ALARM disabled. *)
    
        {REGION Buzzer and Led Alarm}
            BuzzerSilenced     := TRUE;    
            (*Stop blink of LED alarm*)
            Req_BlinkLED_Alarm := FALSE;    
            (*Stop blink of LED alarm*)
            Req_FixLED_Alarm   := GblAlarm;
            
            Req_FixLED_PRG := FALSE;
        {ENDREGION}
        
        {REGION Reset Menu and SubMenu}
            MenuWidget1.ResetWidget();
            SubMenuWidget1.ResetWidget();
        {ENDREGION}
        
        pGD1.GoToLoop(pGD1_LoopList#Alarms);
//    END_IF;    
END_FUNCTION
