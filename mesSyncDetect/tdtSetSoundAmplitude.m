function tdtSetSoundAmplitude( TDT, amp )

invoke( TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.CursorAmp'], amp);
invoke( TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TargetAmp'], amp);

