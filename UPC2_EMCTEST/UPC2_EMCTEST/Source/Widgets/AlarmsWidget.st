/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.1
DATE        : 18/06/2021
DESCRIPTION : Displays alarms.
*/

USING System;
USING System.UI;
USING System.Util;
USING System.Timer;
USING System.Text;

{DEFINE ALR_RESET_TIME 3} (*second*)

{METADATA DEFAULT_SELECTABLE "FALSE"} 
{METADATA WIDGET_TYPE "Graphic"}
{METADATA PREVIEW_STRING "ALARM WIDGET"}
{METADATA SUPPORT_TERMINALS "pGD1"}
{METADATA OCCUPATION "Rectangle;132;64"}
{METADATA ICON "Technology"}
CLASS AlarmsWidget EXTENDS BaseWidget

	VAR PUBLIC
        (**Alarm descriptions*)
        AlarmDescr      : ARRAY[1..noAlrms] OF STRING[66];
        (**Stored variable 1 description*)
        StoreVarDesc1   : ARRAY[1..noAlrms] OF STRING[14];
        (**Stored variable 2 description*)
        StoreVarDesc2   : ARRAY[1..noAlrms] OF STRING[14];        
		x,y : INT;	//auto-assigned
	END_VAR
	
	VAR PRIVATE		
        (**Index used to display next/previus alarm code of array CompactAlrmAct*)
        IdxVis          : INT := 1;  
        (**Counter i*)
        i               : INT;
        (**Counter k*)
        k               : INT := 1;                
        (**Compacted array of active alarms*)
        CompactAlrmAct  : ARRAY[1..noAlrms] OF UINT;       
        (**Counter second for reset*) {ATTRIBUTE UOM SECOND}
        Counter         : UINT;
        (**Code of key pressed*)
        KeyPressed      : UINT;
    END_VAR
	
	METHOD PUBLIC Init	
        //THIS.row := TO_INT(THIS.y / TO_INT(UI_row_height));
        //THIS.col := TO_INT(THIS.x / TO_INT(UI_col_width));
    END_METHOD
    
    {METADATA ACTION "KEY_UP"}
    (**Function called every time KEY UP is pressed*)            
    METHOD PUBLIC KeyUp            
        IdxVis := IdxVis - 1; 
    END_METHOD
    
    {METADATA ACTION "KEY_DOWN"}
    (**Function called every time KEY DOWN is pressed*)
    METHOD PUBLIC KeyDown
        IdxVis := IdxVis + 1;   
    END_METHOD
         
    {METADATA ACTION "KEY_ENTER"}
    (**Function called every time KEY ENTER is pressed*)    
    METHOD PUBLIC KeyEnter   
        IF IdxVis = 0 OR IdxVis = k THEN
            pGD1.GoToMask(pGD1_MaskList#AlarmsLogMsk);
        END_IF;
    END_METHOD  
    
    {METADATA ACTION "KEY_ESC"}
    (**Function called every time KEY ESC is pressed*)    
    METHOD PUBLIC KeyEsc       
        IdxVis := 1; 
        pGD1.GoToLoop(pGD1_LoopList#Loop0);
    END_METHOD
    
    {METADATA ACTION "KEY_PRG"}
    (**Function called every time KEY PRG is pressed*)    
    METHOD PUBLIC KeyPrg   
        pGD1.GoToMask(pGD1_MaskList#MainMask); 
        //AskPwd(0, 0);
    END_METHOD
    
    {METADATA ACTION "KEY_ALARM"}
    (**Function called every time KEY ALARM is pressed*)     
    METHOD PUBLIC KeyAlarm
        BuzzerSilenced     := TRUE;    
        (*Stop blink OF LED alarm*)
        Req_BlinkLED_Alarm := FALSE;            
        (*Stop blink of LED alarm*)
        Req_FixLED_Alarm   := GblAlarm;
        
        GetKeyPressed(KeyPressed, Counter);        
        
        IF Counter >= ALR_RESET_TIME THEN       (*Request to reset all alarms*)
            ResAlrmByHMI   := TRUE;
            BuzzerSilenced := FALSE;
        END_IF;
    END_METHOD
    
    METHOD PUBLIC Draw
        VAR
            (**Alarm description - 1st line*)
            AlarmStr1   : STRING[22];
            (**Alarm description - 2nd line*)
            AlarmStr2   : STRING[22];
            (**Alarm description - 3rd line*)
            AlarmStr3   : STRING[22];
            (**String length check*)
            Lenght      : DINT;
            (**Alarm code*)
            Code        : UINT;
        END_VAR
                  
        HideCursor();
        
        {REGION Creates a compact the list of active alarm.}
            k := 1;
            FOR i := 1 TO TO_INT(UPPER_BOUND(Active_Alrm,1)) DO                
                CompactAlrmAct[i] := 0;             (*Clear the list before to write*)
                
                IF Active_Alrm[i] > 0 THEN          (*Compact the list of active alarm*)
                    CompactAlrmAct[k] := TO_UINT(i); 
                    k := k + 1;                
                END_IF;
            END_FOR; 
        {ENDREGION}
        
        {REGION Check IF no alarm present}
            IF CompactAlrmAct[1] = 0 THEN 
                DrawRect(0,0,132,8,TRUE);
                DrawImage(TO_UINT(Assets.Image.NoAlarms_93x110),0,16);
                DrawString('Press ENTER', 6, 3);
                DrawString('to DATA LOGGER', 7, 3);
                DrawImage(TO_UINT(Assets.Image.HystoryAlarm_Img),0,48);
            END_IF;
        {ENDREGION}

        IF IdxVis > k-1 OR IdxVis < 1 THEN 
            /* ********  INDEX MANAGEMENT ******** */            
            IF IdxVis < 0 THEN 
                IdxVis := k-1;
            END_IF;
            
            IF IdxVis > k THEN 
                IdxVis := 1;
            END_IF;            
            
            {REGION Mask to go inside History Alarms mask.}
                IF (IdxVis = k OR IdxVis = 0) AND CompactAlrmAct[1] <> 0 THEN
                    DrawString('Press ALARM for 3s', 2, 3);
                    DrawString('to reset all alarms', 3, 3);
                    DrawImage(TO_UINT(Assets.Image.StopImg),0,20);
                    DrawString('Press ENTER', 6, 3);
                    DrawString('to DATA LOGGER', 7, 3);
                    DrawImage(TO_UINT(Assets.Image.HystoryAlarm_Img),0,48);
                END_IF;
            {ENDREGION}
        ELSE
            /* ********  ALARMS > 0 ******** */
            IF CompactAlrmAct[1] <> 0 THEN 
                
                Code := CompactAlrmAct[IdxVis];
                    
                {REGION Row 0}
                    DrawRect(0,0,132,8,TRUE);
                    DrawString('Alarm',0,0);
                    DrawStringAligned(TO_STRING(k - 1), 0, TextAlignment#Right);
                    DrawString('/', 0, 21 - TO_INT(LEN(TO_STRING(noAlrms))));
                    DrawString(TO_STRING(TO_UINT(IdxVis)), 0, 21 - (TO_INT(LEN(TO_STRING(noAlrms))))*2);
                {ENDREGION}
                                   
                {REGION Row1}
                    DrawString(alarms.Arr[Code].StrCode, 1, 0);
                {ENDREGION}
                                         
                {REGION Row3-4-5}
                    /* *************  Description length check + Draw ************* */
                    Lenght := LEN(AlarmDescr[Code]);
                
                    IF Lenght > 0 THEN
                        AlarmStr1 := MID(AlarmDescr[Code], 22, 1);
                        DrawStringAligned(AlarmStr1, 3, TextAlignment#Left);
                    END_IF;
                    
                    IF Lenght > 22  THEN
                        AlarmStr2 := MID(AlarmDescr[Code], 22, 23);
                        DrawStringAligned(AlarmStr2, 4, TextAlignment#Left);
                    END_IF;
                    
                    IF Lenght > 44 THEN
                        AlarmStr3 := MID(AlarmDescr[Code], 22, 45);
                        DrawStringAligned(AlarmStr3, 5, TextAlignment#Left);
                    END_IF;
                {ENDREGION}                
            END_IF;
        END_IF;
    END_METHOD
END_CLASS


