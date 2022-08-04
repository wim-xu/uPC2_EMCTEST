/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.1
DATE        : 18/06/2021
DESCRIPTION : Language Selection Widget.
*/

USING System;
USING Assets;
USING System.UI;


{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "Languages"}
{METADATA SUPPORT_TERMINALS "pGD1"}
(**Language string widget*)
CLASS LanguageWidget EXTENDS BaseWidget
	VAR PUBLIC
		x,y : INT;	//auto-assigned
	END_VAR
	
	VAR PRIVATE
        (**Transaltion of language*)
        LangStr     : STRING[22];
        (**Initialization done*)
        InitDone    : BOOL;        
        (**Row of widget*)
        Row         : INT;
		(**Column of widget *)
        Col         : INT;
        (**LanguageID Old*)
        LanguageID_Old : UINT;
	END_VAR	

	
	//mandatory init method
    (**Widget initialization*)
	METHOD PUBLIC Init
		THIS.Row := TO_INT(THIS.y / TO_INT(UI_row_height));
		THIS.Col := TO_INT(THIS.x / TO_INT(UI_col_width));
	END_METHOD
	
	//mandatory draw method
    (**Draw language string*)    
	METHOD PUBLIC Draw
        HideCursor();
        
        IF NOT InitDone THEN
            InitDone := TRUE;
            IF LanguageID <> 0 THEN                 (*Set language for te frist time*)
                SetLanguageID(LanguageID);
                LanguageID_Old := LanguageID;
            ELSE
                RETURN;
            END_IF;
        END_IF;
                                
        (*Update Language String*)
        IF Language.ResMap[LanguageID] = 'EN' THEN
            LangStr := 'ENGLISH';
        ELSIF Language.ResMap[LanguageID] = 'IT' THEN
            LangStr := 'ITALIANO';
        ELSIF Language.ResMap[LanguageID] = 'DE' THEN
            LangStr := 'DEUTCH';
        ELSIF Language.ResMap[LanguageID] = 'FR' THEN
            LangStr := 'FRANCAIS';
        ELSIF Language.ResMap[LanguageID] = 'PT' THEN
            LangStr := 'PORTUGUES';
        END_IF;
        
        DrawStringAligned(LangStr, THIS.Row, TextAlignment#Right);
        
        IF LanguageID <> LanguageID_Old THEN        (*Set new language?*)
            LanguageID_Old := LanguageID;
            SetLanguageID(LanguageID);
        END_IF;
	END_METHOD
	
	{METADATA ACTION "KEY_DOWN"}
    (**Scroll language list down*)    
	METHOD PUBLIC DecreaseLanguageID       
        
        IF LanguageID = Language.LanguagesCount THEN
            LanguageID := 1;
        ELSE
            LanguageID := LanguageID + 1;
        END_IF;
	END_METHOD
    
    {METADATA ACTION "KEY_UP"}
    (**Scroll language list up*)
	METHOD PUBLIC IncreaseLanguageID
        
        IF LanguageID = 1 THEN
            LanguageID := Language.LanguagesCount;
        ELSE
            LanguageID := LanguageID - 1;
        END_IF;
	END_METHOD
    
    {METADATA ACTION "KEY_ENTER"}
    (**Confirm language selection*)
    METHOD PUBLIC GoToMainLoop
        ShowMskLanguage := FALSE;
    END_METHOD
    
    {METADATA ACTION "KEY_ESC"}
    (**Confirm language selection*)
    METHOD PUBLIC GoToMenu
        IF NOT EnLangMskCdwnT THEN
            pGD1.GoToLoop(pGD1_LoopList#SubMenuSettings);
        END_IF;
    END_METHOD    
END_CLASS




{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "LN"}
{METADATA SUPPORT_TERMINALS "pGD1"}
(** Language Acronym string widget. *)
CLASS LanguageAcronymWidget EXTENDS BaseWidget
	VAR PUBLIC
		x,y : INT;	//auto-assigned
	END_VAR
	
	VAR PRIVATE
        Row : INT;
		Col : INT;
	END_VAR	
	
	//mandatory init method
    (** Initialization widget *)
	METHOD PUBLIC Init
		THIS.Row := TO_INT(THIS.y / TO_INT(UI_row_height));
		THIS.Col := TO_INT(THIS.x / TO_INT(UI_col_width));
	END_METHOD
	
	//mandatory draw method
    (** Draw language acronym aligned to the right. *)
	METHOD PUBLIC Draw
        DrawStringAligned(Language.ResMap[TO_INT(GetLanguageID())], THIS.Row, TextAlignment#Right);
	END_METHOD
	
END_CLASS