/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.1
DATE        : 18/06/2021
DESCRIPTION : Language Selection Widget.
*/

USING System;
USING Assets;
USING System.UI;


{METADATA DEFAULT_SELECTABLE "TRUE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "D"}
{METADATA SUPPORT_TERMINALS "pGD1"}
(** Check Service access right widget. *)
CLASS AccessRightWidget  EXTENDS BaseWidget
	VAR PUBLIC
		x,y : INT;	//auto-assigned
        (**Login type necessary to modify parameters (0=User, 1=Service, 2=Manufacturer, 3=System )*)
        LoginType : LOGIN_PASSWORD;
	END_VAR
	
	VAR PRIVATE       
        (**Row of widget*)
        Row         : INT;
		(**Column of widget *)
        Col         : INT;
	END_VAR		
	
    (**Widget initialization*)
	METHOD PUBLIC Init
		THIS.Row := TO_INT(THIS.y / TO_INT(UI_row_height));
		THIS.Col := TO_INT(THIS.x / TO_INT(UI_col_width));
	END_METHOD
		
    (**Draw Dummy variable.*)    
	METHOD PUBLIC Draw
        VAR
            Str : STRING;            
        END_VAR
        
        IF Blink THEN
            IF Access_Sys THEN
                Str := 'G';                 (*God -> System*)
            ELSIF Access_Manuf THEN
                Str := 'M';                 (*Manufacturer*)
            ELSIF Access_Service THEN
                Str := 'S';                 (*Service*)
            ELSE
                Str := 'U';                 (*User*)
            END_IF;            
        END_IF;
    
        DrawString(Str, THIS.Row, THIS.Col);
	END_METHOD	
    
    {METADATA ACTION "KEY_ENTER"}
    (**Checks the access right and displays a warning mask.*)
    METHOD PUBLIC CheckAccessRight        
        
        CASE LoginType OF
            LOGIN_PASSWORD#Service:
                IF Access_User THEN
                    pGD1.GoToMask(pGD1_MaskList#InsertService);
                ELSE
                    pGD1.GoToNextField();    
                END_IF;
            
            LOGIN_PASSWORD#Manufacturer, LOGIN_PASSWORD#System:
                IF Access_User OR Access_Service THEN
                    pGD1.GoToMask(pGD1_MaskList#InsertManufacturer);
                ELSE
                    pGD1.GoToNextField(); 
                END_IF;            
        END_CASE;
    END_METHOD
    
    {METADATA ACTION "KEY_UP"}
    (**GoToPreviousMask.*)
    METHOD PUBLIC GoTo_PreviousMask        
        
        pGD1.GoToPreviousMask();
    END_METHOD
    
    {METADATA ACTION "KEY_DOWN"}
    (**GoToNextMask.*)
    METHOD PUBLIC GoTo_NextMask        
        
        pGD1.GoToNextMask();
    END_METHOD 
END_CLASS

