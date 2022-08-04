USING System;
USING System.Text;
USING System.Timer;

VAR_GLOBAL
    {REGION INSTANCES OF PROGRAMs}    
        Prg_NetFieldbus_Read  : NetFieldbus_Read;        
//      Prg_Unitconfig        : Unitconfig;           
        Prg_InputMng          : InputMng;
        Prg_AlarmsMng         : AlarmsMng;
        Prg_StoreAlarms       : StoreAlarms;
        Prg_OnOffUnit         : OnOffUnit;
//      Prg_Regulation        : Regulation;
        Prg_HoursCounterMng   : HoursCounterMng;            
        Prg_OutputMng         : OutputMng;        
        Prg_NetFieldbus_Write : NetFieldbus_Write;
        Prg_uPC2EMCMain       : uPC2EMCMain;
    {ENDREGION}
    
    (**Delay of activation programs execution*)
    TON_StartExcPrgs          : TON;
    
    SwSafeUpload              : SoftwareSafeUpload;
END_VAR

(*
  Insert here all the programs to be executed in your strategy.
 *)
PROGRAM ProgramsExecutor
    SwSafeUpload(KeybOffOn := KeybOnOff, StartUpload := NOT KeybOnOff);
    
    (*Read Fieldbus netwok*)
    Prg_NetFieldbus_Read();         
    
    //Prg_Unitconfig();    
    //Prg_InputMng();    

    TON_StartExcPrgs(IN := Go_PLC, PT := T#10s);
    
    IF TON_StartExcPrgs.Q THEN
        Prg_AlarmsMng();         
        Prg_StoreAlarms();       
        //Prg_InputMng();
        //Prg_OnOffUnit(); 
        //Prg_Regulation();
        
        //Prg_HoursCounterMng();      
        //Prg_Chiller();
        Prg_uPC2EMCMain();
        //Prg_OutputMng();
        
        (*Log management*)
        //Logs.Check(); 
    ELSE
        (*During pCO start up the display shows OFF*)
        UnitOff := TRUE;            
    END_IF;
    
    (*Write Fieldbus netwok*)
    Prg_NetFieldbus_Write();
END_PROGRAM