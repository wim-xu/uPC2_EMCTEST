USING System;
USING System.UI;
USING System.Timer;
USING System.Math;
USING System.Globalization;
USING Assets;
USING Libs.SignalGeneration_v0_2_0;
USING Libs.GetTime_v0_1_8;


{DEFINE TimeLogoMsk     10}
{DEFINE TimeLanguageMsk 60}
{DEFINE TimeDispWrgPwd  5}

(*Da trasformare in VAR del program HMI.*)
VAR_GLOBAL 
    TON_NoKeyPressGoToMainMask  : TON;
    TON_NoKeyPressAskPwd        : TON;
    TP_AlrmResByHMI             : TP;    
    Ftrg_Buzzer                 : F_TRIG;
    (**Key pressed in HMI*)
    KeyPressed                  : UINT;
    (**Length of the HMI button stroke*)
    KeyPressedCntr              : UINT;
    BlkOnOff                    : BlinkOnOff;    
    
    (**Language Mask coutdown time*)
    {ATTRIBUTE UOM SECOND}
    LangMskCdwnT        : USINT (0..99);
    
    (**Enable Language Mask coutdown time (FALSE=Disable, TRUE=Enable)*)
    EnLangMskCdwnT      : BOOL;
    
    (**Internal state of FB*)
    StateHMI            : State_HMI (State_HMI#Wait..State_HMI#DisplayMainMask) := State_HMI#Wait;   
    
    (**Operation done*)
    OpDone              : BOOL := TRUE;
    
    (**Show "Wrong Password!" inside Login mask*)
    WrngPwd             : BOOL;
    (**Accessed from MainMenu by selecting Alarms log*)
    AlAccessedFromMenu  : BOOL;
END_VAR



PROGRAM HMI
    VAR
        (**Saves current time*)
        {ATTRIBUTE UOM MILLISECOND}
        MemTime         : UDINT;        
        (**Enable the description Var1 of History Alarms widgets (TRUE=View, FALSE= Hidden)*)
        EnStoreVarDesc1 : BOOL := TRUE;
        (**Enable the description Var2 of History Alarms widgets (TRUE=View, FALSE= Hidden)*)
        EnStoreVarDesc2 : BOOL := TRUE;        
    END_VAR
    
    IF ClientDeletingMem THEN
        RETURN;
    END_IF;
    
    {REGION WIDGETs: BIND OF VARIABLES}
        //You must give to "Menu Widget" the variable value.
        MenuWidget1.PwdType.Bind(LoginPwdType);
        //You must give to "History Alarms Widget" the variable value.
        HistoryAlarmsWidget1.EnStoreVarDesc1 := EnStoreVarDesc1;
        HistoryAlarmsWidget1.EnStoreVarDesc2 := EnStoreVarDesc2;
    {ENDREGION}
    
    RetainMemWrites := GetRetainWritingsNumber();   //Used in mask Info
    
    BlkOnOff(
                In      := TRUE,
                T_On    := 1,
                T_Off   := 1,
            
                Out     => Blink
            );
    
    {REGION STARTUP MANAGEMENT: COMPANY LOGO AND LANGUAGE SELECTION MASK}
        (*Transition of the state*) 
        CASE StateHMI OF
            State_HMI#Wait:
                MemTime  := CurrSysT;                
                StateHMI := State_HMI#DisplayLogoMask;
            
            State_HMI#DisplayLogoMask:
                IF CurrSysT - MemTime >= TimeLogoMsk*1000 THEN
                    OpDone := TRUE;
                    
                    IF ShowMskLanguage THEN                       
                        MemTime         := CurrSysT;
                        EnLangMskCdwnT  := TRUE;
                        
                        StateHMI        := State_HMI#DisplayMainMask;
                    ELSE
                        StateHMI := State_HMI#DisplayMainMask;
                    END_IF;
                END_IF;
            
            State_HMI#DisplayLanguageMask: 
                IF      NOT ShowMskLanguage                                 (*Key ENTER pressed inside widget to confirm language*)
                    OR  (CurrSysT - MemTime >= TimeLanguageMsk*1000) THEN   (*Key ENTER not pressed inside widget *) 
                    OpDone          := TRUE;
                    ShowMskLanguage := FALSE;
                    EnLangMskCdwnT  := FALSE;
                                            
                    StateHMI := State_HMI#DisplayMainMask;
                ELSE
                    LangMskCdwnT := TimeLanguageMsk - TO_USINT((CurrSysT - MemTime)/1000);
                END_IF;
        END_CASE;
    
        (*Action in the state*)
        CASE StateHMI OF
            State_HMI#DisplayLogoMask:
                IF OpDone THEN
                    IF status=DisplayStatus#PLAN THEN
                        DisplayLED_BACKGROUND := FALSE; 
                        pGD1.GoToMask(pGD1_MaskList#MainMask);
                    ELSIF  status=DisplayStatus#SEV_SEGMENTS THEN
                        SevenSegments.GoToMask(SevenSegments_MaskList#Mask0);
                    END_IF;
                END_IF;
            
            State_HMI#DisplayLanguageMask:
                IF OpDone THEN
                     IF status=DisplayStatus#PLAN THEN
//                        SetLanguageID(LanguageID);
                        pGD1.GoToMask(pGD1_MaskList#MainMask);
                    ELSIF  status=DisplayStatus#SEV_SEGMENTS THEN
                        SevenSegments.GoToMask(SevenSegments_MaskList#Mask0);
                    END_IF;
                END_IF;
            
            State_HMI#DisplayMainMask:
                IF OpDone THEN
                    IF status=DisplayStatus#PLAN THEN
//                        SetLanguageID(LanguageID);
                        pGD1.GoToMask(pGD1_MaskList#MainPage);
                    ELSIF  status=DisplayStatus#SEV_SEGMENTS THEN
                        SevenSegments.GoToMask(SevenSegments_MaskList#Mask0);
                    END_IF;
                END_IF;
        END_CASE;
        
        OpDone := FALSE;
    {ENDREGION}
    
    {REGION MANAGEMENT QUICK MENU}
        IdxImgQM := SEL(Blink, IdxQM, IdxQM + 3);
    {ENDREGION}
    
    {REGION RESET ALARMS BY TwoRows}
        TP_AlrmResByHMI(
                        	IN := ResAlrmByHMI,
                        	PT := T#5s
                        );
        
        ResAlrmByHMI := TP_AlrmResByHMI.Q;
    {ENDREGION} 
    
    
    {REGION UNIT OF MEASURE USED IN HMI (S.I. / IMPERIAL)}       
        CASE UoMZoneHMI OF            
            UOM_ZONE#SI:
                pGD1.SetUIZone(SI);
            
            UOM_ZONE#Imperial:
                pGD1.SetUIZone(Imperial);          
        ELSE
            pGD1.SetUIZone(NONE);
        END_CASE;
    {ENDREGION}    
        
    (*check which keys are pressed*)
    GetKeyPressed(KeyPressed, KeyPressedCntr);
        
    {REGION RETURN TO MAIN MASK}
        (*If any key is pressed after 300s returns to main mask automatically*)
//        TON_NoKeyPressGoToMainMask(IN := KeyPressed = NO_KEY, PT := TO_TIME(TO_UDINT(ReturnMainMaskTime)*1000));
        
//        IF TON_NoKeyPressGoToMainMask.Q THEN        
//            (*return to main mask*)            
            
//            IF status=DisplayStatus#PLAN THEN
//                DisplayLED_BACKGROUND := TRUE;
//                pGD1.GoToMask(pGD1_MaskList#MainMask);
//                {REGION Reset Widget Menu/Submenu}
//                MenuWidget1.ResetWidget();
//                SubMenuWidget1.ResetWidget();
//                {ENDREGION}
//            END_IF;
            
            
//        END_IF;
    {ENDREGION}
    
    {REGION ASK PASSWORD WHEN PRESS PRG KEY}
        TON_NoKeyPressAskPwd(IN := KeyPressed = NO_KEY, PT := T#600s);
        
        IF TON_NoKeyPressAskPwd.Q THEN              
            (*logout*)            
            Access_Sys     := FALSE;
            Access_User    := FALSE;
            Access_Service := FALSE;
            Access_Manuf   := FALSE;            
        END_IF;
    {ENDREGION}
    
    {REGION LED MANAGEMENT}
        {REGION MANAGEMENT OF LED ALARM (code 12)}
            Ftrg_Buzzer(CLK := GblAlarm);
            IF Ftrg_Buzzer.Q THEN
                (*Alarm configurated as AUTO-RESET: in this case the alarm condition is no more reset*)
                BuzzerSilenced     := FALSE;
                Req_BlinkLED_Alarm := FALSE;
                Req_FixLED_Alarm   := FALSE;
            END_IF;
            
            DisplayBlinkLED_Alarm  := Req_BlinkLED_Alarm;
            DisplayLED_Alarm       := Req_FixLED_Alarm;  
            
            SetBuzzer(GblAlarm AND NOT BuzzerSilenced AND En_Buzzer); 
        {ENDREGION}
        
        {REGION MANAGEMENT OF LED PRG (code 7)}
            DisplayBlinkLED_PRG    := Req_BlinkLED_PRG;
            DisplayLED_PRG         := Req_FixLED_PRG; 
        {ENDREGION}
    
        {REGION MANAGEMENT OF LEDs (code 24): BACKGROUND / ESC / ↑ / ENTER / ↓}
            IF KeyPressed <> NO_KEY THEN
                DisplayLED_BACKGROUND := FALSE;                
            END_IF;
        {ENDREGION}
    {ENDREGION}
    
    IF WrngPwd THEN
        IF CurrSysT-MemTimePwdWrg > TimeDispWrgPwd*1000 THEN
            WrngPwd := FALSE;
        END_IF;
    END_IF;
END_PROGRAM