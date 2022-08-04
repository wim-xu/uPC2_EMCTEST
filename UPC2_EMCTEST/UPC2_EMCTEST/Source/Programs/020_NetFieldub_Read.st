USING System;
USING System.Timer;

VAR_GLOBAL
    Dly_EnTmplate: TON;
END_VAR

PROGRAM NetFieldbus_Read
    
        //==============================================
        // ENABLING OF TEMPLATE
        //==============================================
//        ClientModbus_pCO.Info.Enabled := En_FB1; 
    
        //==============================================
        // READ FROM TEMPLATE IF SERVER IS ONLINE
        //==============================================
//        Dly_EnTmplate(IN := ClientModbus_pCO.Info.Enabled, PT := T#3s);
        //# Alarms.Table.Al_ServerOffline.Info.Trigger := Dly_EnTmplate.Q  AND (NOT ClientModbus_pCO.Info.IsOnline);
    
        //==============================================
        // COMUNICATION BETWEEN CLIENT/SALVE BAORD
        //==============================================
    	IF En_FB1 THEN        
                    
            {REGION READS FROM SERVER BOARD (INPUT STATUS -> COILS)}
            
                //..........................................
                // PUT HERE YOUR VARIABLEs
                //..........................................
            // := ClientModbus_pCO.IR_0_CANCELLAMI5;
            {ENDREGION}
                            
            {REGION READS PARAMETERS FROM SERVER BOARD (INPUT REGISTER)}
                //# RemProbeT := ClientModbus_pCO.IR_00_RemProbeT;
            
            
                //..........................................
                // PUT HERE YOUR VARIABLEs
                //..........................................
            // := ClientModbus_pCO.IS_0_CANCELLAMI6;
            {ENDREGION}
    END_IF;
    
END_PROGRAM