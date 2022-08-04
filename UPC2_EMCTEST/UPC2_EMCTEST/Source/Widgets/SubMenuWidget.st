/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.0
DATE        : 18/06/2021
DESCRIPTION : Displays Sub-menu.
*/

USING System;
USING Assets;
USING System.UI;
USING System.Util;
USING System.Math;



{METADATA DEFAULT_SELECTABLE "FALSE"}
{METADATA WIDGET_TYPE "Graphic"}
{METADATA PREVIEW_STRING "Menu"}
{METADATA SUPPORT_TERMINALS "pGD1"}
{METADATA OCCUPATION "Rectangle;132;64"}
{METADATA ICON "Technology"}
CLASS SubMenuWidget EXTENDS BaseWidget

	VAR PUBLIC        
        x : INT;	            //auto-assigned
        y : INT;	            //auto-assigned
	END_VAR
		
    VAR CONSTANT PRIVATE
        {REGION USER CUSTOMIZATION NEEDED!}
            (**Images number used by menu. *)
            NoImages     : INT   := 6;
            (**Languages number (EN, IT,..).*)
            NoLanguages  : INT   := 5;
                    
            (**Menu images. Pays attention to array organization:
              * - 1st column is for WHITE images
              * - 2nd column is for BLACK images.*)
            Images          : ARRAY[1..NoImages, 1..2] OF STRING[30] := 
                                                                    [
                                                                    (*White*)       (*Black*)    
                                                            (*1*)  'Data_Time',         'Data_Time_black',       
                                                            (*2*)  'UoM_12x16',         'UoM_black_12x16',      
                                                            (*3*)  'Language_2',        'Language_2_black',      
                                                            (*4*)  'SerialPort',        'SerialPort_black',      
                                                            (*5*)  'PwdChange',         'PwdChange_black',    
                                                            (*6*)  'Initializiation',   'Initializiation_black'
                                                                   ];
            (**Languages used by Software.*)
            Languages       : ARRAY[1..NoLanguages] OF STRING[2] := ['EN', 'IT', 'DE', 'FR', 'PT'];
            
            (**Menu texts. Pays attention to array organization:
              * - 1st column is for EN language
              * - 2nd column is for IT language.
              * - ...*)
            Tests           : ARRAY[1..NoImages, 1..NoLanguages] OF STRING[19] := 
                                                                    [
                                                                    (*EN*)               (*IT*)                   (*DE*)                  (*FR*)                  (*PT*)    
                                                            (*1*)  'Date/Time',         'Data/Ora',              'Date/Time',             'Date/Time',            'Date/Time',       
                                                            (*2*)  'UoM',               'UoM',                   'UoM',                   'UoM',                  'UoM',      
                                                            (*3*)  'Language',          'Lingua',                'Sprache',               'Langue',               'Idioma',      
                                                            (*4*)  'Network',           'Rete',                  'Netzwerk',              'Réseau',               'Red',      
                                                            (*5*)  'Pwd Change',        'Cambio Pwd',            'PWT aendern',           'Changement mdp',       'Cambiar contraseîa',    
                                                            (*6*)  'Initialization',    'Inizializzazione',      'Initialisierung',       'Initialisation',       'Inicializacion'
                                                                   ];
            
            MenuTitle           : ARRAY[1..1, 1..NoLanguages] OF STRING[22] := 
                                                                    [
                                                                    (*EN*)               (*IT*)                 (*DE*)                  (*FR*)               (*PT*)    
                                                            (*1*)  'Settings menu',      'Menù impostazioni',   'Menue einstellungen',  'Menu réglages',     'Menu configuracion'
                                                                    ];
        {ENDREGION}
        
        {REGION NOT MODIFY!}
            (*Window managemnt: Max 3 images*)
            IdFirstImg   : INT := 1;
            IdLastImg    : INT := NoImages;
            IdWindowLow  : INT := 1;
            IdWindowHigh : INT := 3;
        {ENDREGION}        
    END_VAR
	
    VAR PRIVATE
        (**Initialization of arrays*)
        INIT        : BOOL;
        (**Current language ID*)
        CurrLng     : UINT;
        (**Index of window low*)
        IdWindowL   : INT := IdWindowLow;
        (**Index of window high*)
        IdWindowH   : INT := IdWindowHigh;
        (**Error during the reading of images*)
        ErrImg      : BOOL;
        (**Error during the reading of langages*)
        ErrLng      : BOOL;      
        
        (**Index of selected image inside menu using keys ↑,↓*)
        IdImg           : INT := IdFirstImg;
        (** Create a relationship between the images provided by the user (array Images[ ]) 
          * and the index of images assigned by STone (array Image.ResMap[ ]).*)
        Images_TO_ID    : ARRAY[1..NoImages, 1..2] OF USINT;
        (** Create a relationship between the languages provided by the user (array Languages[ ]) 
          * and the index of images assigned by STone (array Language.ResMap[ ]).*)
        Languages_TO_ID : ARRAY[1..NoLanguages] OF USINT;        
	END_VAR    
	
    (** Set CurrLng.*)
	METHOD PUBLIC Init
        VAR
            i,j          : DINT;
            (**Found the index inside Image.ResMap array of i-image belonging to Images[i,1] array.*)
            ImgGrp1Found : BOOL;
            (**Found the index inside Image.ResMap array of i-image belonging to Images[i,2] array.*)
            ImgGrp2Found : BOOL;
        END_VAR
        
        CurrLng := GetLanguageID();
        
        (** Create a relationship between the images provided by the user (array Images[ ]) 
          * and the index of images assigned by STone (array Image.ResMap[ ]).
          * NOTE: The variable Err=TRUE if same images are not found inside Image.ResMap[ ].
        *)
        FOR i := LOWER_BOUND(Images, 1) TO UPPER_BOUND(Images, 1) DO
            ImgGrp1Found := FALSE;
            ImgGrp2Found := FALSE;
            
            FOR j := LOWER_BOUND(Image.ResMap, 1) TO UPPER_BOUND(Image.ResMap, 1) DO
                IF Images[i,1] = Image.ResMap[j] AND NOT ImgGrp1Found THEN
                    Images_TO_ID[i,1] := TO_USINT(j);
                    ImgGrp1Found := TRUE;
                END_IF;                
            
                IF Images[i,2] = Image.ResMap[j] AND NOT ImgGrp2Found THEN
                    Images_TO_ID[i,2] := TO_USINT(j);
                    ImgGrp2Found := TRUE;                    
                END_IF;
                
                IF ImgGrp1Found AND ImgGrp2Found THEN
                    EXIT;
                END_IF;
            END_FOR;
            
            IF NOT ImgGrp1Found OR NOT ImgGrp2Found THEN
                ErrImg := TRUE;
                EXIT;
            END_IF;
        END_FOR;
	END_METHOD
	
	(**Draws the menu*)
	METHOD PUBLIC Draw
        VAR
            i,j          : DINT;
            (**Current language ID*)
            IDLng        : UINT;
            (**Position Y of balck selection bar.*)
            BarPosY      : INT;
            
            (**Found the index inside Language.ResMap array of i-language belonging to Languages[i] array.*)
            LngFound     : BOOL;
        END_VAR
        
        HideCursor();
        ClearGraphics();
        
        {REGION INITIALIZATION LANGUAGES}
            IF CurrLng <> GetLanguageID() OR NOT INIT THEN
                INIT    := TRUE;
                CurrLng := GetLanguageID();
                
                FOR i := LOWER_BOUND(Languages, 1) TO UPPER_BOUND(Languages, 1) DO
                    LngFound := FALSE;
                    FOR j := LOWER_BOUND(Language.ResMap, 1) TO UPPER_BOUND(Language.ResMap, 1) DO
                        IF Languages[i] = Language.ResMap[j] AND NOT LngFound THEN
                            Languages_TO_ID[i] := TO_USINT(j);
                            LngFound           := TRUE;
                            EXIT;
                        END_IF;
                    END_FOR;
                    
                    IF NOT LngFound THEN
                        ErrLng := TRUE;
                        EXIT;
                    END_IF;
                END_FOR; 
            END_IF;        
        {ENDREGION}
        
        IF ErrImg OR ErrLng THEN            
    		IF ErrImg THEN
                DrawString('Error: Images not found!', 0, 0);
            END_IF;
            IF ErrLng THEN
                DrawString('Error: Language not found!', 1, 0);
            END_IF;
            RETURN;
        END_IF;
        
        {REGION GET LANGUAGE ID}
            FOR i := LOWER_BOUND(Languages_TO_ID, 1) TO UPPER_BOUND(Languages_TO_ID, 1) DO
                IF TO_UINT(Languages_TO_ID[i]) = CurrLng THEN
                    IDLng := TO_UINT(i);
                    EXIT;
                END_IF;
            END_FOR;
        {ENDREGION}       
        
        {REGION Draws 1St row}
            DrawRect(0, 0, 132, 8, TRUE);                                                                               //Draws 1st row
            DrawStringAligned(MenuTitle[1, IDLng], 0, TextAlignment#Left);        
            DrawStringAligned(TO_STRING(IdImg) + '/'+ TO_STRING(NoImages), 0, TextAlignment#Right);        
        {ENDREGION}
        
        {REGION Draws 3 images using IdImg variable.}
            (*NOTE: IdImg is update by keys ↑,↓*)
            IF IdImg = IdWindowL THEN
                DrawImage(TO_UINT(Images_TO_ID[IdWindowL, 2]), 0, 16);          //2*8=16 -> IMAGE IS SELECTED
                BarPosY := 16;
            ELSE
                DrawImage(TO_UINT(Images_TO_ID[IdWindowL, 1]), 0, 16);          //2*8=16
            END_IF;
        
            DrawString(Tests[IdWindowL, IDLng], 3, 3);
        
            IF IdWindowL + 1 <= IdWindowH THEN
                IF IdImg = IdWindowL + 1 THEN
                    DrawImage(TO_UINT(Images_TO_ID[IdWindowL + 1, 2]), 0, 32);  //4*8=32 -> IMAGE IS SELECTED              
                    BarPosY := 32;
                ELSE
                    DrawImage(TO_UINT(Images_TO_ID[IdWindowL + 1, 1]), 0, 32);  //4*8=32 
                END_IF;
                DrawString(Tests[IdWindowL +1, IDLng], 5, 3);
            END_IF;
            
            IF IdWindowL + 2 <= IdWindowH THEN
                IF IdImg = IdWindowL + 2 THEN
                    DrawImage(TO_UINT(Images_TO_ID[IdWindowH, 2]), 0, 48);      // 6*8=48 -> IMAGE IS SELECTED           
                    BarPosY := 48;
                ELSE
                    DrawImage(TO_UINT(Images_TO_ID[IdWindowH, 1]), 0, 48);      // 6*8=48 
                END_IF;
                DrawString(Tests[IdWindowH, IDLng], 7, 3);
            END_IF;
        {ENDREGION}
        
        (*Draws the selection bar*)
        DrawRect(12, BarPosY, 120, 16, TRUE);
	END_METHOD
	
	{METADATA ACTION "KEY_DOWN"}
    (**Function called every time KEY DOWN is pressed.*)
	METHOD PUBLIC KeyDown
        IdImg := IdImg + 1;
        
        IF IdImg > IdLastImg THEN
            IdImg     := IdFirstImg;
            IdWindowL := IdWindowLow;
            IdWindowH := MIN(IdLastImg, IdFirstImg + 2);
            
        ELSIF IdImg > IdWindowH THEN            
            IdWindowL := IdWindowL + 1;
            IdWindowH := IdWindowH + 1;
        END_IF;        
	END_METHOD
        
    {METADATA ACTION "KEY_UP"}
    (**Function called every time KEY UP is pressed.*)            
 	METHOD PUBLIC KeyUp            
        IdImg := IdImg - 1;
        
        IF IdImg < IdFirstImg THEN
            IdImg     := IdLastImg;
            IdWindowL := MAX(IdFirstImg, IdLastImg - 2);
            IdWindowH := IdLastImg;
            
        ELSIF IdImg < IdWindowL THEN            
            IdWindowL := IdWindowL - 1;
            IdWindowH := IdWindowH - 1;
        END_IF; 
    END_METHOD  

    {METADATA ACTION "KEY_ESC"}
    (**Function called every time KEY PRG is pressed.*)    
 	METHOD PUBLIC KeyEsc
        THIS.ResetWidget();
        pGD1.GoToLoop(pGD1_LoopList#Menu); 
    END_METHOD
    
    {METADATA ACTION "KEY_ENTER"}
    (**Function called every time KEY ENTER is pressed.*)    
 	METHOD PUBLIC KeyEnter          
        CASE IdImg OF
            1: 
                GetDate_From_DateFormat(DateFrmt, LocDateAndTime, DateTimeBypGD1.Hour, DateTimeBypGD1.Minute, DateTimeBypGD1.Second, DateP1, DateP1Lmin, DateP1Lmax, DateP2, DateP2Lmin, DateP2Lmax, DateP3, DateP3Lmin, DateP3Lmax);
            
                pGD1.GoToLoop(pGD1_LoopList#DateTime);           //  'Date/Time'        
            2: 
                pGD1.GoToLoop(pGD1_LoopList#UoM);                //  'UoM',      
            3: 
                pGD1.GoToLoop(pGD1_LoopList#Language);           //  'Language',      
            4: 
                pGD1.GoToLoop(pGD1_LoopList#Network);            //  'Netwok',      
            5: 
                pGD1.GoToLoop(pGD1_LoopList#ChangePwds);         //  'Change PWDs',
            6: 
                pGD1.GoToLoop(pGD1_LoopList#Initialization);     //  'Initialization'              
        END_CASE;    
    END_METHOD
    
    (**Resets widget's bar selection.*)
    METHOD ResetWidget 
        IdImg     := 1;
        IdWindowL := IdWindowLow;
        IdWindowH := IdWindowhigh;
    END_METHOD
END_CLASS      
