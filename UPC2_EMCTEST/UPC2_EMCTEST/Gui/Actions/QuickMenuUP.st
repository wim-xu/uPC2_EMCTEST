USING System;
USING System.UI;

(** Function for UP key of main mask. *)
FUNCTION QuickMenuUP
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR

    IF IdxQM = QUICK_MENU#Info THEN
        IdxQM := QUICK_MENU#OnOff;
    ELSE
        IdxQM := IdxQM + 1;
    END_IF;
END_FUNCTION
