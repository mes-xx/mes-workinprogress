TDT.RP = actxcontrol('TDevAcc.X');
invoke(TDT.RP,'ConnectServer', 'Local');
TDT.Dev{1}=invoke(TDT.RP,'GetDeviceName',0);
TDT.tag_zTime=[TDT.Dev{1} '.zTime'];
TDT.call_GetTag='GetTargetVal'; % used to access a single variable
TDT.call_SetTag='SetTargetVal';
TDT.call_ReadTag='ReadTargetV'; % used to access a sequence of data from a buffer
TDT.call_WriteTag='WriteTargetV';

invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakeSize1'], .000400);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakeSize2'], .000400);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakeSize3'], .000100);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakeSize4'], .000100);

invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakePeriod1'], 70);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakePeriod2'], 80);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakePeriod3'], 90);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.FakePeriod4'], 100);

invoke(TDT.RP, 'CloseConnection');