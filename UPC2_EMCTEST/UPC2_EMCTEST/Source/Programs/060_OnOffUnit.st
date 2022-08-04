USING system;
USING System.Math;
USING System.Timer;

PROGRAM OnOffUnit
    
    {REGION UNIT ON/OFF COMMAND}
        UnitOn :=       NOT Al_SrsUnit
                    AND KeybOnOff                                                  
                    AND (NOT En_DinAlrm OR NOT Prg_InputMng.Din1)                   (* Remote Alarm*)     
                    AND (NOT En_DinOffOn OR Prg_InputMng.Din2)                      (**)                           
                    AND (NOT (En_BmsOffOn AND BMS2_Online) OR BmsOffOn);            (*Unit works in stand-alone mode in case of BMS offline!*)
        
        UnitOff := NOT UnitOn;
    
        (*UNIT STATUS*)
        IF En_DinOffOn AND NOT Prg_InputMng.Din2 THEN
            UnitStatus := UNIT_STATUS#OffByDI;
        ELSIF  NOT KeybOnOff THEN  
            UnitStatus := UNIT_STATUS#OffByKeyboard;            
        ELSIF En_BmsOffOn AND BMS2_Online AND NOT BmsOffOn THEN
            UnitStatus := UNIT_STATUS#OffByBMS;
        ELSIF Al_SrsUnit THEN    
            UnitStatus := UNIT_STATUS#OffByAlarm;
        ELSIF UnitOn THEN    
            UnitStatus := UNIT_STATUS#UnitON;            
        END_IF;    
    {ENDREGION}

END_PROGRAM