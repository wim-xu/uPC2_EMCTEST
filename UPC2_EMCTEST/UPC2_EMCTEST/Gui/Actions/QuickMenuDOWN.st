USING System;
USING System.UI;

(** Function for DOWN key of main mask. *)
FUNCTION QuickMenuDOWN
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR    
    
    IF IdxQM = QUICK_MENU#OnOff THEN
        IdxQM := QUICK_MENU#Info;
    ELSE
        IdxQM := IdxQM - 1;
    END_IF;
END_FUNCTION
