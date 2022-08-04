USING System.Math;

PROGRAM NetFieldbus_Write
    
	IF En_FB1 THEN        
    {REGION COMUNICATION BETWEEN CLIENT/SALVE BAORD}
                
        {REGION WRITES PARAMETERS INSIDE SERVER BOARD (COIL STATUS)}    
        
            //..........................................
            // PUT HERE YOUR VARIABLEs
            //..........................................
//            ClientModbus_pCO.CS_0_UnitOn := UnitOn;
        {ENDREGION}
                        
        {REGION WRITES PARAMETERS INSIDE SERVER BOARD (HOLDING REGISTERS)}

            //..........................................
            // PUT HERE YOUR VARIABLEs
            //..........................................
            
        {ENDREGION}
    {ENDREGION}
END_IF;
    
END_PROGRAM