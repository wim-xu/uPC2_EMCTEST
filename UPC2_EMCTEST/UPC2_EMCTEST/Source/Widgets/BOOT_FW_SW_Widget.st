/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.0
DATE        : 24/06/2021
DESCRIPTION : Displays BOOT\FW\SW version.
*/

USING System;
USING System.Timer;
USING System.Math;
USING System.UI;
USING System.Util;
USING System.Text;

{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "BOOT:          x.x.xxx"}
{METADATA SUPPORT_TERMINALS "pGD1"}
CLASS BOOT_FW_SW_Widget EXTENDS BaseWidget

	VAR PUBLIC
		x, y : INT;	//auto-assigned
	END_VAR
	
	VAR PRIVATE		
        Row     : INT;
        //Col   : INT;
        (**System Info structure*)
        SysInfo : SystemInfo;
        (**BOOT version*)
        BOOT    : STRING;
        (**FW version*)
        FW      : STRING;
	END_VAR
	
	METHOD PUBLIC Init
		THIS.Row := TO_INT(THIS.y / TO_INT(UI_row_height));
        //THIS.Col := TO_INT(THIS.x / TO_INT(UI_col_width));
        
        GetSystemInfo(THIS.SysInfo);
        BOOT := TO_String(THIS.SysInfo.BootloaderVersion);
        FW   := TO_String(THIS.SysInfo.FirmwareVersion);
	END_METHOD	
	
	METHOD PUBLIC Draw
        (*1st string*)
        DrawString('BOOT ver.: ', THIS.Row, 0);
        DrawStringAligned(
                            MID(BOOT,  1, 0) 
                            + '.'+
                            MID(BOOT,  1, 0+1)
                            + '.' +
                            MID(BOOT,  3, 0+1+1),                    
                            THIS.Row, TextAlignment#Right
                            );
        
        (*2nd string*)
        DrawString('FW ver.: ', THIS.Row + 1, 0);
        DrawStringAligned(
                            MID(FW,  1, 0) 
                            + '.'+
                            MID(FW,  1, 0+1)
                            + '.' +
                            MID(FW,  3, 0+1+1),                    
                            THIS.Row +1, TextAlignment#Right
                            );
        
        (*3rd string*)
        DrawString('SW ver.:', THIS.Row + 2, 0);
        DrawStringAligned(__PROJ_VER__, THIS.Row +2, TextAlignment#Right);
	END_METHOD
END_CLASS