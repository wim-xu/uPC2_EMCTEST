/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.0
DATE        : 18/06/2021
DESCRIPTION : Displays date and time.
*/

USING System;
USING System.Timer;
USING System.Math;
USING System.UI;
USING System.Util;
USING System.Text;

{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "DD/MM/YY"}
{METADATA SUPPORT_TERMINALS "pGD1"}
CLASS DateWidget EXTENDS BaseWidget

	VAR PUBLIC
        x,y : INT;	
	END_VAR
	
	VAR PRIVATE
        dateTime    : DATE_AND_TIME;
	    years,months,days,hours,minutes,seconds,milliseconds : UINT;
        InEditing   : BOOL;
        format      : STRING;
        row         : INT;
	    col         : INT;
	END_VAR
    
    METHOD PUBLIC Init
        (*Set WdFormat string with the current date format*)
        CASE DateFrmt OF
            DateFormat#DDMMYYYY: 
                format := 'dd/MM/yy';
            DateFormat#MMDDYYYY:
                format := 'MM/dd/yy';
            DateFormat#YYYYMMDD:
                format := 'yy/MM/dd';
        END_CASE;
        
        GetLocalTime(dateTime);
    END_METHOD
    
	METHOD PUBLIC Draw
        THIS.row := TO_INT(THIS.y / TO_INT(UI_row_height));
		THIS.col := TO_INT(THIS.x / TO_INT(UI_col_width));
        
        IF NOT InEditing THEN
            (*Set WdFormat string with the current date format*)
            CASE DateFrmt OF
                DateFormat#DDMMYYYY: 
                    format := 'dd/MM/yy';
                DateFormat#MMDDYYYY:
                    format := 'MM/dd/yy';
                DateFormat#YYYYMMDD:
                    format := 'yy/MM/dd';
            END_CASE;
            
            GetLocalTime(dateTime);
        END_IF;
        
        SPLIT_DT(dateTime, years, months, days, hours, minutes, seconds, milliseconds);
        
        IF years <2000 THEN
            years := 00;
        ELSE
            years := years - 2000;
        END_IF;
        
        DrawString(THIS.DateString(),row,col);
	END_METHOD

    METHOD PRIVATE DateString : STRING
        VAR
            strDate : STRING;
        END_VAR
        strDate := LEFT(format, 8);
        strDate := Replace(strDate, FORMAT('%02d', days), 2, Find(format, 'dd'));
        strDate := Replace(strDate, FORMAT('%02d', months), 2, Find(format, 'MM'));
        strDate := Replace(strDate, FORMAT('%02d', years), 2, Find(format, 'yy'));
        DateString := strDate;
	END_METHOD
END_CLASS

{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "HH:MM"}
{METADATA SUPPORT_TERMINALS "pGD1"}
CLASS ShortTimeWidget EXTENDS BaseWidget
    VAR PUBLIC
        x,y : INT;	
	END_VAR
	
	VAR PRIVATE
        dateTime  : DATE_AND_TIME;
	    years,months,days,hours,minutes,seconds,milliseconds : UINT;
        InEditing : BOOL;
        row       : INT;
	    col       : INT;
	END_VAR
    
    METHOD PUBLIC Init
        GetLocalTime(dateTime);
    END_METHOD
    
	METHOD PUBLIC Draw
        THIS.row := TO_INT(THIS.y / TO_INT(UI_row_height));
		THIS.col := TO_INT(THIS.x / TO_INT(UI_col_width));
        
        IF NOT InEditing THEN
            GetLocalTime(dateTime);
        END_IF;
        
        SPLIT_DT(dateTime, years, months, days, hours, minutes, seconds, milliseconds);
        
        DrawString(THIS.TimeString(),row,col);
	END_METHOD

    METHOD PRIVATE TimeString : STRING
        
		TimeString := FORMAT('%02d', THIS.hours) + ':' + FORMAT('%02d', THIS.minutes);
	END_METHOD
END_CLASS

{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Text"}
{METADATA PREVIEW_STRING "Week"}
{METADATA SUPPORT_TERMINALS "pGD1"}
CLASS WeekWidget EXTENDS BaseWidget
    VAR PUBLIC
        x,y : INT;	
	END_VAR
	
	VAR PRIVATE
        dateTime  : DATE_AND_TIME;
	    week      : DayOfWeek;
        InEditing : BOOL;
        row       : INT;
	    col       : INT;
	END_VAR
    
    METHOD PUBLIC Init
        GetLocalTime(dateTime);
        week := DAY_OF_WEEK(dateTime);
    END_METHOD
    
	METHOD PUBLIC Draw
        THIS.row := TO_INT(THIS.y / TO_INT(UI_row_height));
		THIS.col := TO_INT(THIS.x / TO_INT(UI_col_width));
        
        IF NOT InEditing THEN
            GetLocalTime(dateTime);
            week := DAY_OF_WEEK(dateTime);
        END_IF;
        
        DrawString(THIS.WeekString(),row,col);
	END_METHOD

    METHOD PRIVATE WeekString : STRING
        (*Set WeekString string with the week*)
        CASE week OF
            DayOfWeek#Monday:
                WeekString := 'Mon';
            DayOfWeek#Tuesday:
                WeekString := 'Tue';
            DayOfWeek#Wednesday:
                WeekString := 'Wed';
            DayOfWeek#Thursday:
                WeekString := 'Thu';
            DayOfWeek#Friday:
                WeekString := 'Fri';
            DayOfWeek#Saturday:
                WeekString := 'Sat';
            DayOfWeek#Sunday:
                WeekString := 'Sun';
        END_CASE;
	END_METHOD
END_CLASS