TDT.use_TDevAcc=1;

Init_ActX; % the generic function that initializes the actx connection

TDT.num_chan=16; % number of channels being recorded in OpenEx

TDT.coef_size_lesstwo=22; % number of neural sort coefficients to get on each channel

TDT.tag_SortCoef=[TDT.Dev{1} '.cEA~'];

TDT.tag_SortThresh=[TDT.Dev{1} '.aEA~'];

for i=1:1:TDT.num_chan,
    
    invoke(TDT.RP, TDT.call_WriteTag, [TDT.tag_SortCoef int2str(i)], 0, sort_param.coef(i,:));
    invoke(TDT.RP, TDT.call_SetTag, [TDT.tag_SortThresh int2str(i)], sort_param.thresh(i,:));
    
end

Close_ActX; % common function used to close an open actX connection