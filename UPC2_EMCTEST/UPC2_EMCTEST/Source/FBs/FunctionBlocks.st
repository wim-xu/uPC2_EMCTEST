USING System;
USING System.Timer; 
USING System.Math;


(*
------------------------------------------------------------------------------------------
        INSERT HERE ALL YOUR FUNCTION-BLOCKS
------------------------------------------------------------------------------------------
*)

(** 
 * Allow to upload the software safely.
 * When a full download request from the IDE starts, the variable "KeybOffOn" will be set to FALSE.
 * Then after 10s, if the StartUpload is TRUE the download will start.
 *)
FUNCTION_BLOCK SoftwareSafeUpload
    VAR_IN_OUT
        (**Keyboard On/Off*)
        KeybOffOn   : BOOL;
    END_VAR
    VAR_INPUT
        (**Upload start-up command*)
        StartUpload : BOOL;
    END_VAR
    VAR
        (**Wait before start software upload inside ACU*)
        TON_WAIT_DOWNLOAD : TON;
        FirstCycle        : BOOL := TRUE;
    END_VAR
    
    IF FirstCycle THEN
        FirstCycle := FALSE;
        // SET YOUR SEMAPHOREs HERE
        SetIDESema(TO_INT(IDESEMA_FULLDOWNLOAD), TO_INT(SEMA_STATUS_WAIT));
    END_IF;

    IF GetFullDownloadRequest() THEN                    
        // Request to put in "safety status" the unit.
        KeybOffOn := FALSE;
        
        (* A write operation in RETAIN/PERSISTENT MEMORY (ie: KeybOnOff=FALSE) became effective after 5s -> Inside the POP-UP window -> 
           if you select button "BY-PASS" (... and NOT WAIT 10s) and the UNIT is ON -> at ACU re-start probably KeybOnOff will be TRUE. *)
        TON_WAIT_DOWNLOAD(IN := TRUE, PT := t#10s);      
        
        // When UNIT is in "safety status", the full download can be done.
        IF TON_WAIT_DOWNLOAD.Q AND StartUpload THEN
            SetIDESema(TO_INT(IDESEMA_FULLDOWNLOAD), TO_INT(SEMA_STATUS_GO));
        END_IF;
    ELSE
        TON_WAIT_DOWNLOAD(IN := FALSE);
        SetIDESema(TO_INT(IDESEMA_FULLDOWNLOAD), TO_INT(SEMA_STATUS_WAIT));
    END_IF;
END_FUNCTION_BLOCK