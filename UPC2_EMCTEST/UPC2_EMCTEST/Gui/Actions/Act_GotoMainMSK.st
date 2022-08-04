USING System;
USING System.UI;

FUNCTION Act_GotoMainMSK
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR

    pGD1.GoToMask(pGD1_MaskList#MainMask);
END_FUNCTION
