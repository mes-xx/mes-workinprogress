% set 'ReadDone' high in order to reset 'ReadReady'
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.ReadDone'], 1);

% make sure 'ReadRead' is reset
while invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.ReadReady'])
end

% now set 'ReadDone' low again so the TDT can set ReadReady high when the
% time comes
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.ReadDone'], 0);