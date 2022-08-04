USING System;
USING System.UI;

FUNCTION ReturnToSubMenuSettings
	VAR_INPUT
		keyPressed:UINT;
		keyCounter:UINT;
	END_VAR
    pGD1.GoToLoop(pGD1_LoopList#SubMenuSettings);

END_FUNCTION