USING System;
USING System.Math;
USING System.Timer;

USING Libs.Counters;



PROGRAM HoursCounterMng
    VAR
        (**Unit On HoursCounter FB*)
        HrsCntr_UnitOn : HoursCounter;
        (**Used for debug: n° of seconds for hour (Set 0=3600s)*)
        HrsCntrAdjust  : UINT;
        
    END_VAR    
    
    {REGION UNIT}
        HrsCntr_UnitOn(
                        In             := UnitOn,
                        ThrshAlrm      := 50*100,                       (* Threshold in hundreds *)
                        HrsPrstUpdRate := HRS_PRST_UPD_RATE,
                        Adjust         := HrsCntrAdjust,
                        ResAlrm        := UnitOnResHrs,
                        ResTotCnt      := ResTotCnt,
                        
                        Hours          => UnitOnHrs,
                      //Alrm           => BOOL,                         (* PAY ATTENTION! Connect here your alarm *)
                        
                        Partial_PRST   := UnitOnHrsPartial,
                        Total_PRST     := UnitOnHrsTot
                    );
        
        IF UnitOnResHrs THEN 
            UnitOnResHrs := FALSE;                                      (* Auto-Reset *)          
        END_IF; 
    {ENDREGION}
    
    (*--------------------------------
               HOURS COUNTER RESET
      --------------------------------*)
    IF ResTotCnt THEN
        ResTotCnt := FALSE;                                             (* Auto-Reset *) 
    END_IF;
END_PROGRAM