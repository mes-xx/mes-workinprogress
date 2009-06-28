%% Closes ActiveX protocol

if TDT.use_TDevAcc==1,
    invoke(TDT.RP, 'CloseConnection');
elseif TDT.use_TDevAcc==0,
    invoke(TDT.RP, 'Halt');
end;