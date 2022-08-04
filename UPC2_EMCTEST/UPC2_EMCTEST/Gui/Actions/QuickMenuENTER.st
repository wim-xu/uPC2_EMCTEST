USING System;
USING System.UI;

(** #Alla pressione del tasto enter accede al loop indicato dal quick menu. *)
FUNCTION QuickMenuENTER
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR

    CASE IdxQM OF
        QUICK_MENU#OnOff:
            pGD1.GotoLoop(pGd1_LoopList#ONOFF);
        
        QUICK_MENU#Set:
            pGD1.GotoLoop(pGd1_LoopList#SET);

        QUICK_MENU#Info:
            pGD1.GotoLoop(pGd1_LoopList#Loop0);
    END_CASE; 
END_FUNCTION
