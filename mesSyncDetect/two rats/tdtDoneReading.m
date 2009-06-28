% set 'ReadDone' high in order to reset 'ReadReady'
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.ReadDone' Parameters.ParTagSuffix], 1);

% make sure 'ReadRead' is reset
while invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.ReadReady' Parameters.ParTagSuffix])
end

% now set 'ReadDone' low again so the TDT can set ReadReady high when the
% time comes
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.ReadDone' Parameters.ParTagSuffix], 0);