/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.0
DATE        : 25/06/2021
DESCRIPTION : Displays project GUID.
*/

USING System;
USING System.Timer;
USING System.Math;
USING System.UI;
USING System.Util;
USING System.Text;

{METADATA DEFAULT_SELECTABLE "TRUE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "TimeZONE: (UTC+01:00) Rome"}
{METADATA SUPPORT_TERMINALS "pGD1"}
CLASS TimezoneWidget EXTENDS BaseWidget

	VAR PUBLIC
		x, y : INT;	//auto-assigned
	END_VAR
	
	VAR PRIVATE		
        Row     : INT;
        //Col   : INT;
        IdxMax  : DINT;
        IdxMin  : DINT;
	END_VAR
	
	METHOD PUBLIC Init
		THIS.Row := TO_INT(THIS.y / TO_INT(UI_row_height));
        //THIS.Col := TO_INT(THIS.x / TO_INT(UI_col_width));
        IdxMin := LOWER_BOUND(TimeZoneName, 1);
        IdxMax := UPPER_BOUND(TimeZoneName, 1);
	END_METHOD	
	
	METHOD PUBLIC Draw
        VAR
            StrLen : DINT;
        END_VAR
        
        StrLen := LEN(TimeZoneName[Timezone]);
                
        DrawString( MID(TimeZoneName[Timezone], SEL(StrLen < 22, 22, StrLen), 0), THIS.Row, 0);                   (*1st ROW*)
        
        IF StrLen>44 OR (23<=StrLen AND StrLen<=44) THEN
            DrawString( MID(TimeZoneName[Timezone], SEL(StrLen < 44, 22, StrLen-22), 22), THIS.Row +1, 0);        (*2nd ROW*)
        END_IF;
        IF StrLen>66 OR (45<=StrLen AND StrLen<=66) THEN
            DrawString( MID(TimeZoneName[Timezone], SEL(StrLen < 66, 22, StrLen-44), 44), THIS.Row +2, 0);        (*3rd ROW*)
        END_IF;
        CASE StrLen OF
            67..88:
                DrawString( MID(TimeZoneName[Timezone], SEL(StrLen < 88, 22, StrLen-66), 66), THIS.Row +3, 0);    (*4th ROW*)
        END_CASE;       
	END_METHOD    
    
    {METADATA ACTION "KEY_ENTER"}
    (**Function called every time KEY ENTER is pressed and released.*)    
 	METHOD PUBLIC KeyEnter
        VAR
            Err_TimeZone : UINT;
        END_VAR
        Err_TimeZone  := SetTimeZone(TimeZonePOSIX[Timezone]);
        pgd1.GoToNextField();
    END_METHOD
    
    {METADATA ACTION "KEY_UP"}
    (**Function called every time KEY UP is pressed.*)            
 	METHOD PUBLIC KeyUp
        
        IF TO_DINT(TimeZone) - 1 < IdxMin THEN
            TimeZone := TO_UINT(IdxMax);
        ELSE
            TimeZone := TimeZone - 1;
        END_IF; 
    END_METHOD 
    
    {METADATA ACTION "KEY_DOWN"}
    (**Function called every time KEY DOWN is pressed.*)
	METHOD PUBLIC KeyDown
        IF TO_DINT(TimeZone) + 1 > IdxMax THEN
            TimeZone := TO_UINT(IdxMin);
        ELSE
            TimeZone := TimeZone + 1;
        END_IF;        
	END_METHOD
END_CLASS