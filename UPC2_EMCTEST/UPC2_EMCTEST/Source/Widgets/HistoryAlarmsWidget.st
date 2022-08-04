/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.1
DATE        : 18/06/2021
DESCRIPTION : Displays history alarms.
*/

USING System;
USING System.UI;
USING System.Util;
USING System.Timer;
USING System.Text;


{METADATA DEFAULT_SELECTABLE "FALSE"} 
{METADATA WIDGET_TYPE "Graphic"}
{METADATA PREVIEW_STRING "ALARM HISTORY"}
{METADATA SUPPORT_TERMINALS "pGD1"}
{METADATA OCCUPATION "Rectangle;132;64"}
{METADATA ICON "Technology"}
CLASS HistoryAlarmsWidget EXTENDS BaseWidget

	VAR PUBLIC
        (**Alarm descriptions*)
        AlarmDescr      : ARRAY[1..noAlrms] OF STRING[66];
        (**Enable StoreVarDesc1*)
        EnStoreVarDesc1 : BOOL;                     //BindableVariable;
        (**Stored variable 1 description*)
        StoreVarDesc1   : ARRAY[1..noAlrms] OF STRING[14];
        (**Enable StoreVarDesc2*)
        EnStoreVarDesc2 : BOOl;                     // BindableVariable;
        (**Stored variable 2 description*)
        StoreVarDesc2   : ARRAY[1..noAlrms] OF STRING[14];
		x,y : INT;	//auto-assigned        
	END_VAR
	
	VAR PRIVATE		
        (**Index used to display next/previus alarm code of array CompactAlrmAct*)
        IdxVis           : INT;    
        (**Date and time*)
        MyDateTime      : DateTime;
        (**Date displayed*)
        DateTimeString : STRING;
        
        (*Saving of LogAlrmIdx*)
        LogAlrmIdx_Old  : UINT;
    END_VAR
	
	METHOD PUBLIC Init	
        //THIS.row := TO_INT(THIS.y / TO_INT(UI_row_height));
        //THIS.col := TO_INT(THIS.x / TO_INT(UI_col_width));
    END_METHOD
    
    {METADATA ACTION "KEY_UP"}
    (**Function called every time KEY UP is pressed.*)            
 	METHOD PUBLIC KeyUp            
        IdxVis := IdxVis + 1;
        
        IF IdxVis > UINT_TO_INT(noAlrmsLog) THEN
            (*Goes to the first array position*)
            IdxVis := 1;
        ELSIF Log_Alarm[IdxVis].Code = 0 THEN
            (*Goes to the first array position*)
            IdxVis := 1; 
        END_IF;    
    END_METHOD
    	
    {METADATA ACTION "KEY_DOWN"}
    (**Function called every time KEY DOWN is pressed.*)
	METHOD PUBLIC KeyDown
        IdxVis := IdxVis - 1;
        IF IdxVis < 1 THEN
            IdxVis := UINT_TO_INT(noAlrmsLog);
            IF Log_Alarm[IdxVis].Code = 0 THEN
                IdxVis := UINT_TO_INT(LogAlrmIdx);                    
            END_IF;
        END_IF;   
	END_METHOD
        
    {METADATA ACTION "KEY_ESC"}
    (**Function called every time KEY ESC is pressed.*)    
 	METHOD PUBLIC KeyEsc           
        IF AlAccessedFromMenu THEN
            AlAccessedFromMenu := FALSE;
            pGD1.GoToLoop(pGD1_LoopList#Loop0);
        ELSE
            pGD1.GoToMask(pGD1_MaskList#AlarmsMsk);
        END_IF;
    END_METHOD        

    {METADATA ACTION "KEY_ENTER"}
    (**Function called every time KEY ENTER is pressed.*)    
 	METHOD PUBLIC KeyEnter         
        //Necessary do nothing! In this way widget works!
    END_METHOD 
    
	METHOD PUBLIC Draw
        VAR
            (**First line of description*)
            AlarmStr1 : STRING[22];
            (**Second line of description*)
            AlarmStr2 : STRING[22];
            (**Third line of description*)
            AlarmStr3 : STRING[22];
            (**String length check*)
            Lenght : DINT;
            (**Alarm ID*)
            AlrID : UINT;
        END_VAR            
         
        HideCursor();
        
        /* *********  UPDATE INDEX ********* */
        IF LogAlrmIdx <> LogAlrmIdx_Old THEN                
            IdxVis := TO_INT(LogAlrmIdx); (*/Update index*)               
        END_IF;
        LogAlrmIdx_Old := LogAlrmIdx;
        
        {REGION ALARM HISTORY MANAGEMENT}
        IF LogAlrmIdx = 0 THEN  
            /* ********  ALARMS = 0 ******** */
            DrawRect(0, 0, 132, 8, TRUE);
            DrawImage(TO_UINT(Assets.Image.NoAlarms_93x110), 0, 16);
              
        ELSE 
            /* ********  ALARMS > 0 ******** */
            AlrID := Log_Alarm[IdxVis].Code;
            /* ********  Date&Time ******** */
            SPLIT_DT(Log_Alarm[IdxVis].TimeStamp, MyDateTime);
            DateTimeString :=         FORMAT('%02d', MyDateTime.Hour) + ':' + FORMAT('%02d', MyDateTime.Minute) 
                              + ' ' + FORMAT('%02d', MyDateTime.Day) + '/' + FORMAT('%02d', MyDateTime.Month) + '/' + FORMAT('%02d', MyDateTime.Year);
                        
            {REGION Row 0}
                DrawRect(0,0,132,8,TRUE);
                DrawString('Data logger Record:', 0, 0);
                DrawStringAligned(TO_STRING(IdxVis), 0, TextAlignment#Right);               
            {ENDREGION}
            
            {REGION Row 1}
                DrawString(alarms.Arr[AlrID].StrCode, 1, 0);
                /* *************  Alarms status Check ************* */
                IF Log_Alarm[IdxVis].Status = 0 THEN
                    //Row1
                    DrawImage(TO_UINT(Assets.Image.StartImg), 24, 8);
                    DrawString(DateTimeString, 1, 6);
                ELSIF Log_Alarm[IdxVis].Status = 1 THEN
                    //Row2
                    DrawImage(TO_UINT(Assets.Image.StopImg), 24, 8);
                    DrawString(DateTimeString, 1, 6);
                END_IF;
            {ENDREGION}

            {REGION Row 3-4-5}
                /* *************  Description length check + Draw ************* */
                Lenght := LEN(AlarmDescr[AlrID]);
                IF Lenght > 0 THEN
                    AlarmStr1 := MID(AlarmDescr[AlrID], 22, 1);
                    DrawStringAligned(AlarmStr1, 3, TextAlignment#Left);
                END_IF;
            
                IF Lenght > 22  THEN
                    AlarmStr2 := MID(AlarmDescr[AlrID], 22, 23);
                    DrawStringAligned(AlarmStr2, 4, TextAlignment#Left);
                END_IF;
                
                IF Lenght > 44 THEN
                    AlarmStr3 := MID(AlarmDescr[AlrID], 22, 45);
                    DrawStringAligned(AlarmStr3, 5, TextAlignment#Left);
                END_IF;
            {ENDREGION}            
            
            {REGION Row 6}
                /* *************  Description 2 length check + Variable ************* */                
                IF EnStoreVarDesc1 THEN
                    Lenght := LEN(StoreVarDesc1[AlrID]);
                    IF Lenght > 0 AND Lenght <= 14 THEN
                        DrawStringAligned(StoreVarDesc1[AlrID], 6, TextAlignment#Left);
                        DrawStringAligned(FORMAT('%.2f', Log_Alarm[IdxVis].Values[0].REAL), 6, TextAlignment#Right);
                    END_IF;
                END_IF;                
            {ENDREGION}
            
            {REGION Row 7}
                /* *************  Description 3 length check + Variable ************* */                
                IF EnStoreVarDesc2 THEN
                    Lenght := LEN(StoreVarDesc1[AlrID]);
                    IF Lenght > 0 AND Lenght <= 14 THEN
                        DrawStringAligned(StoreVarDesc2[AlrID], 7, TextAlignment#Left);
                        DrawStringAligned(FORMAT('%.2f', Log_Alarm[IdxVis].Values[1].REAL), 7, TextAlignment#Right);
                    END_IF;
                END_IF;
            {ENDREGION}
        END_IF;
        {ENDREGION}  
	END_METHOD
END_CLASS