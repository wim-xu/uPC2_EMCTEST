USING System;

(* 0 highest priority, 10 lowest *)
CONFIGURATION __CONFIGURATION__
	RESOURCE __RESOURCE__ ON RUNTIMETARGET
		TASK ExceptionTask (SYSTEM := EVENT_EXCEPTION, PRIORITY := 0);
		    PROGRAM ExceptionInstance WITH ExceptionTask : ExceptionManager;
			
        (**Task to manage user interface*)
        TASK UITask(EVENT := UI_EVENT, PRIORITY := 2);                      //, AUTOSTART :=0);
            PROGRAM HMI_Instance      WITH UITask : HMI;                    // Before this!
		    PROGRAM UIInstance        WITH UITask : UIManager;              // Must be the last prg.
        
		TASK MainTask (INTERVAL := MAIN_TASK_INTERVAL, PRIORITY := 3);
		    PROGRAM MainInstance WITH MainTask : Main;
        
        
        /* power event demo */
        TASK ExceptionUltracapTask (SYSTEM := EVENT_ULTRACAP_POWER OR EVENT_STOP_ULTRACAP_POWER, PRIORITY := 1);
		PROGRAM ExceptionUltracapInstance WITH ExceptionUltracapTask : ExceptionUltracapManager;
        
	END_RESOURCE
END_CONFIGURATION

{METADATA NOT_AN_ACTION}
FUNCTION ManageKey : BOOL
	VAR_INPUT
		keyPressed, keyCounter : UINT;
	END_VAR
    
//	pGD1.OnGui(keyPressed, keyCounter);
    CASE status OF
        DisplayStatus#PLAN: 
            pgd1.Init();
            pGD1.OnGui(keyPressed, keyCounter);
        
        DisplayStatus#SEV_SEGMENTS:
            SevenSegments.Init();
            SevenSegments.OnGUI(keyPressed, keyCounter);
    END_CASE;
    ManageKey := TRUE;
END_FUNCTION

VAR_GLOBAL
    PowerLossEvt : INT := 0;
    PowerRiseEvt : INT := 0;
END_VAR

PROGRAM ExceptionUltracapManager
    VAR_TEMP
        evt : Event;
    END_VAR
 GetCurrentEvent(evt);
 IF (evt.Mask = EVENT_ULTRACAP_POWER)  THEN  
    PowerLossEvt := PowerLossEvt + 1;
 END_IF;   
 IF (evt.Mask = EVENT_STOP_ULTRACAP_POWER)  THEN  
    PowerRiseEvt := PowerRiseEvt + 1;
 END_IF;   
END_PROGRAM