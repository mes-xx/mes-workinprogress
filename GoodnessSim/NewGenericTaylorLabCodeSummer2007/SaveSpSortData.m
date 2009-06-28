TDT.num_chan = 36;

TDT.RP = actxcontrol('TDevAcc.X');
%% Connect to local server
invoke(TDT.RP,'ConnectServer', 'Local');
%% Get device name (needed for tag names to access parameters on pentusa)
TDT.Dev{1}=invoke(TDT.RP,'GetDeviceName',0);


%% Determine tag names and function calls to access TDT pentusa
TDT.call_GetTag='GetTargetVal'; % used to access a single variable
TDT.call_ReadTag='ReadTargetV'; % used to access a sequence of data from a buffer


sortData = zeros(TDT.num_chan, 96);
for i = 1:TDT.num_chan
    sortData(i, :) = double(invoke(TDT.RP, TDT.call_ReadTag, [TDT.Dev{1} '.cEA~' num2str(i)], 0, 96));
    threshData(i) = invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.aEA~' num2str(i)]);
end


[filename, pathname, filterindex] = uiputfile('*.spk', 'Save Spikes as');

fileData = [sortData'; threshData];
dlmwrite([pathname filename], fileData, '\t');



