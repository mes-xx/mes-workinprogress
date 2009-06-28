TDT.use_TDevAcc=1;

Init_ActX;

TDT.tag_timing=[TDT.Dev{1} '.dPULS~1'];
TDT.tag_time=[TDT.Dev{1} '.tPULS~1'];
TDT.tag_a=[TDT.Dev{1} '.aPULS~1'];
TDT.tag_b=[TDT.Dev{1} '.bPULS~1'];

invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.goPULS~1'], 1);

pause(2);

invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.goPULS~1'], 0);

timings(1,:)=double(invoke(TDT.RP, TDT.call_ReadTag, TDT.tag_timing, 0, 384));
timings(2,:)=double(invoke(TDT.RP, TDT.call_ReadTag, TDT.tag_time, 0, 384));

timing(1,:)=double(invoke(TDT.RP, TDT.call_ReadTag, TDT.tag_a, 0, 16));
timing(2,:)=double(invoke(TDT.RP, TDT.call_ReadTag, TDT.tag_b, 0, 16));


Close_ActX;
