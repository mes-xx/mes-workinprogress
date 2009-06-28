Init_ActX;

% get a bunch of parameters from the TDT

Parameters.RefChan = invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.RefChan']);
Parameters.RefEnable = invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.RefEnable']);

for i = 1:8 % for each of the 8 channels we record...
    
    tagName = [TDT.Dev{1} '.Chan' int2str(i)];
    Parameters.Chan(i) = invoke(TDT.RP, TDT.call_GetTag, tagName);
    
    tagName = [TDT.Dev{1} '.sSortCode' int2str(i)];
    Parameters.SortCode(i) =  invoke(TDT.RP, TDT.call_GetTag, tagName);
    
    tagName = [TDT.Dev{1} '.sThresh' int2str(i)];
    Parameters.Thresh(i) = invoke(TDT.RP, TDT.call_GetTag, tagName);
    
    tagName = [TDT.Dev{1} '.sCoef' int2str(i)];
    Parameters.SortCoef(i) = invoke(TDT.RP, TDT.call_ReadTag, tagName);
    
end

% save the parameters to file
[file,path] = uiputfile('TDT_Parm.mat','Save file name');
oldDir = pwd;
cd(path);
save(file, 'Parameters');
cd(oldDir);