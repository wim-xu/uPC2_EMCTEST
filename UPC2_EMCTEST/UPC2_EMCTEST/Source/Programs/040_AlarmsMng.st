USING System;
USING System.Math;
USING System.Timer;
VAR_GLOBAL
    EEpRetainErrorOccurred : BOOL := FALSE;
    event : Event;
    error : DINT;
    taskId : INT;
    Err_ID : INT(0..100);
END_VAR

{DEFINE Diff_ALM_U_NTC  0.5}
{DEFINE Diff_ALM_U_V  0.3}
{DEFINE Diff_ALM_U_A  0.36}

PROGRAM AlarmsMng     

    VAR_TEMP
        i : INT;
    END_VAR
    
    {REGION ExceptionInstance}
        Alarms.Table.Al_RetainSavedTooOften.Info.Trigger := ExceptionInstance.ExceptionError = ERR_RETAIN_SAVE_TOO_OFTEN;
        Alarms.Table.Al_NFCSavedTooOften.Info.Trigger    := ExceptionInstance.ExceptionError = ERR_NFC_SAVE_TOO_OFTEN;
        ExceptionInstance.ExceptionError                 := 0;   (*PAY ATTENTION! Reset of output.*)
    {ENDREGION}     
    GetCurrentEvent(event);
    IF event.EventType = VMSystemEvent AND event.Mask = TO_DWORD(EVENT_EXCEPTION) THEN
        taskId := TO_INT(event.Data);
        GetLastTaskErrorCodeError(taskId, error);
        CASE error OF
            ERR_RETAIN_INIT_FAIL,
            ERR_RETAIN_NOT_INTITIALIZED,
            ERR_RETAIN_BEGIN_FAIL,
            ERR_RETAIN_WRITE_BLOCK_FAIL,
            ERR_RETAIN_END_FAIL,
            ERR_RETAIN_BACKUP_FAIL,
            ERR_RETAIN_READ_BLOCK_FAIL,
            ERR_RETAIN_CORRUPTED,
            ERR_RETAIN_ERROR_ACCESS,
            ERR_RETAIN_WRITING_ERROR,
            ERR_RETAIN_READING_ERROR:
                EEpRetainErrorOccurred := TRUE;
        END_CASE;
        (*Resume the task, reset the task error*)
        ResumeTask(taskId, error, 0);
    END_IF;
    
//    Alarms.Table.Al_Din1Alrm.Info.Trigger := Prg_InputMng.Din1 AND En_DinAlrm;
    
//    //High Temperature alarms
//    IF W_InTemp>=15.0 AND Unit_On_Off THEN
//        Alarms.Table.Al_HiTemp.Info.Trigger := TRUE;
//    ELSE
//        Alarms.Table.Al_HiTemp.Info.Trigger := FALSE;
//    END_IF;
    
//    //Antifreese alaem
//    Alarms.Table.Al_Afreese.Info.Trigger := W_InTemp<=3.0 AND Unit_On_Off;
    
//    //Broken probe alarm
//    Alarms.Table.Al_Prb.Info.Trigger := AL_Prb_W_InTemp;
    FOR i := 1 TO 24 DO
        CASE i OF
            1, 2, 4, 5, 7, 10, 11, 12, 14: 
                InputValAlarms[i] := InputValueR[i] > 7.5+Diff_ALM_U_NTC OR InputValueR[i] < 7.5-Diff_ALM_U_NTC;
            3:
                InputValAlarms[i] := InputValueR[i] > 2.5+Diff_ALM_U_V OR InputValueR[i] < 2.5-Diff_ALM_U_V;
            6:
                InputValAlarms[i] := InputValueR[i] > 1.0+Diff_ALM_U_V OR InputValueR[i] < 1.0-Diff_ALM_U_V;
            8,13:
                InputValAlarms[i] := InputValueR[i] > 5.0+Diff_ALM_U_V OR InputValueR[i] < 5.0-Diff_ALM_U_V;
            9:
                InputValAlarms[i] := InputValueR[i] > 12.0+Diff_ALM_U_A OR InputValueR[i] < 12.0-Diff_ALM_U_A;
            
            ELSE
                InputValAlarms[i] :=(DInputValue[i - 14] XOR DefaultDInputValue[i - 14]);
        END_CASE;
    END_FOR;
    
    Err_ID := 0;
    FOR i := 1 TO TO_INT(noAlrms) DO
        IF Active_Alrm[i]<>0 THEN
            Err_ID := i;
            EXIT;
        END_IF;
    END_FOR;
        Alarms.Table.Al_U1_PrbAlrm.Info.Trigger := AinAlarms[1];
        Alarms.Table.Al_U2_PrbAlrm.Info.Trigger := AinAlarms[2];
        Alarms.Table.Al_U3_PrbAlrm.Info.Trigger := AinAlarms[3];
        Alarms.Table.Al_U4_PrbAlrm.Info.Trigger := AinAlarms[4];
        Alarms.Table.Al_U5_PrbAlrm.Info.Trigger := AinAlarms[5];
        Alarms.Table.Al_U6_PrbAlrm.Info.Trigger := AinAlarms[6];
        Alarms.Table.Al_U7_PrbAlrm.Info.Trigger := AinAlarms[7];
        Alarms.Table.Al_U8_PrbAlrm.Info.Trigger := AinAlarms[8];
        Alarms.Table.Al_U9_PrbAlrm.Info.Trigger := AinAlarms[9];
        Alarms.Table.Al_U10_PrbAlrm.Info.Trigger := AinAlarms[10];
        Alarms.Table.Al_U11_PrbAlrm.Info.Trigger := CurrentIOInfo.U>10 AND AinAlarms[11];
        Alarms.Table.Al_U12_PrbAlrm.Info.Trigger := CurrentIOInfo.U>11 AND AinAlarms[12];
        Alarms.Table.Al_U1_ValAlrm.Info.Trigger := InputValAlarms[1];
        Alarms.Table.Al_U2_ValAlrm.Info.Trigger := InputValAlarms[2];
        Alarms.Table.Al_U3_ValAlrm.Info.Trigger := InputValAlarms[3];
        Alarms.Table.Al_U4_ValAlrm.Info.Trigger := InputValAlarms[4];
        Alarms.Table.Al_U5_ValAlrm.Info.Trigger := InputValAlarms[5];
        Alarms.Table.Al_U6_ValAlrm.Info.Trigger := InputValAlarms[6];
        Alarms.Table.Al_U7_ValAlrm.Info.Trigger := InputValAlarms[7];
        Alarms.Table.Al_U8_ValAlrm.Info.Trigger := InputValAlarms[8];
        Alarms.Table.Al_U9_ValAlrm.Info.Trigger := InputValAlarms[9];
        Alarms.Table.Al_U10_ValAlrm.Info.Trigger := InputValAlarms[10];
        Alarms.Table.Al_U11_ValAlrm.Info.Trigger := CurrentIOInfo.U>10 AND InputValAlarms[11];
        Alarms.Table.Al_U12_ValAlrm.Info.Trigger := CurrentIOInfo.U>11 AND InputValAlarms[12];
        Alarms.Table.Al_DI1Alrm.Info.Trigger := InputValAlarms[15];
        Alarms.Table.Al_DI2Alrm.Info.Trigger := InputValAlarms[16];
        Alarms.Table.Al_DI3Alrm.Info.Trigger := InputValAlarms[17];
        Alarms.Table.Al_DI4Alrm.Info.Trigger := InputValAlarms[18];
        Alarms.Table.Al_DI5Alrm.Info.Trigger := EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND InputValAlarms[19];
        Alarms.Table.Al_DI6Alrm.Info.Trigger := EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND InputValAlarms[20];
        Alarms.Table.Al_DI7Alrm.Info.Trigger := CurrentIOInfo.ID > 6 AND InputValAlarms[21];
        Alarms.Table.Al_DI8Alrm.Info.Trigger := CurrentIOInfo.ID > 7 AND InputValAlarms[22];
        Alarms.Table.Al_DI9Alrm.Info.Trigger := CurrentIOInfo.ID > 8 AND InputValAlarms[23];
        Alarms.Table.Al_DI10Alrm.Info.Trigger := CurrentIOInfo.ID > 9 AND InputValAlarms[24];
        Alarms.Table.Al_cPCOe1ERR.Info.Trigger := Cpcoe1_Err;
        Alarms.Table.Al_cPCOe2ERR.Info.Trigger := Cpcoe2_Err;
        Alarms.Table.Al_cPCOe3ERR.Info.Trigger := CurrentIOInfo.NO > 10 AND Cpcoe3_Err;
        Alarms.Table.Al_DisplayERR.Info.Trigger :=NOT DisplayIsOnline;
        Alarms.Table.Al_BMS1ERR.Info.Trigger :=NOT pCOWeb_BMS1.Info.Online;   
        Alarms.Table.Al_ETH1ERR.Info.Trigger :=NOT Supervisor_ETH1.Info.Online;
        Alarms.Table.Al_ValveDriveERR.Info.Trigger:= EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND (EVD_EVO_MBSErr.DevErr<>0 OR EVD_EVO_Alr.Al_ConnectionBoardDrvB OR EVD_EVO_Alr.Al_EEPROM OR EVD_EVO_Alr.Al_EmergencyClosing
                                                                                                    OR EVD_EVO_Alr.Al_HwIncompatible OR EVD_EVO_Alr.Al_IncompleteClosing OR EVD_EVO_Alr.Al_MotorVlvA OR EVD_EVO_Alr.Al_MotorVlvB);
        Alarms.Table.Al_S1_Alrm.Info.Trigger := EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND (EVD_EVO_S1Value > 5.3 OR EVD_EVO_S1Value < 4.7 OR EVD_EVO_S1Alarm);
        Alarms.Table.Al_S2_Alrm.Info.Trigger := EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND (EVD_EVO_S2Value > 8.0 OR EVD_EVO_S2Value < 7.0 OR EVD_EVO_S2Alarm);
        Alarms.Table.Al_S3_Alrm.Info.Trigger := EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND (EVD_EVO_S3Value > 5.3 OR EVD_EVO_S3Value < 4.7 OR EVD_EVO_S3Alarm);
        Alarms.Table.Al_S4_Alrm.Info.Trigger := EVD_EVOinstance.DeviceEvdEvo.Info.isOnline AND (EVD_EVO_S4Value > 8.0 OR EVD_EVO_S4Value < 7.0 OR EVD_EVO_S4Alarm);
END_PROGRAM
