
if strcmp(questdlg('Load Spike Data'),'Yes')

    % load data from file
    [filename, pathname, filterindex] = uigetfile('*.spk','Select spike file');
    fileData = dlmread([pathname filename], '\t');

    [r, c] = size(fileData);

    threshData = fileData(r, :);
    sortData = fileData(1:r-1, :)';

    % write data to TDT
    for i = 1:c
        invoke(TDT.RP, TDT.call_WriteTag, [TDT.Dev{1} '.cEA~' num2str(i)], 0, single(sortData(i, :)));
        invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.aEA~' num2str(i)], threshData(i));
    end
    
    clear threshData;
    clear sortData;
    clear fileData;
    

end
