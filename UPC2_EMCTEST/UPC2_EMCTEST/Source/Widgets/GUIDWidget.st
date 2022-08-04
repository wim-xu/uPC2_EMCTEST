/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.0
DATE        : 24/06/2021
DESCRIPTION : Displays project GUID.
*/

USING System;
USING System.Timer;
USING System.Math;
USING System.UI;
USING System.Util;
USING System.Text;

{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "GUID: xxxxxxxx-xxxx-xx"}
{METADATA SUPPORT_TERMINALS "pGD1"}
CLASS GUIDWidget EXTENDS BaseWidget

	VAR PUBLIC
		x, y : INT;	//auto-assigned
	END_VAR
	
	VAR PRIVATE		
        Row : INT;
        //Col : INT;
        (**Prject information*)
        InfoProject     : ProjectInfo;
	END_VAR
	
	METHOD PUBLIC Init
		THIS.Row := TO_INT(THIS.y / TO_INT(UI_row_height));
        //THIS.Col := TO_INT(THIS.x / TO_INT(UI_col_width));
        GetProjectInfo(THIS.InfoProject);
	END_METHOD	
	
	METHOD PUBLIC Draw
        (*1st string*)
        DrawString( 
                    'GUID: ' +
                    MID(THIS.InfoProject.ProjectID,  8, 0) 
                    + '-'+
                    MID(THIS.InfoProject.ProjectID,  4, 0+8)
                    + '-' +
                    MID(THIS.InfoProject.ProjectID,  2, 0+8+4),                    
                    THIS.Row, 0
                    );
        
        (*2nd string*)
        DrawString(
                    MID(THIS.InfoProject.ProjectID,  2, 0+8+4+2)
                    + '-' +
                    MID(THIS.InfoProject.ProjectID,  4, 0+8+4+4)
                    + '-' +
                    MID(THIS.InfoProject.ProjectID, 12, 0+8+4+4+4),
                    THIS.Row+1, 0
                    );
	END_METHOD
END_CLASS