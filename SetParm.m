% this file loads the parameters stored by ReadParm.m

[FileName,PathName] = uigetfile('*.mat');
oldDir = pwd;
cd(PathName);
load(FileName);
cd(oldDir);

Init_ActX;

invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.RefChan'], Parameters.RefChan);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.RefEnable'], Parameters.RefEnable);

for i = 1:8 % for each of the 8 channels we record...
    
    tagName = [TDT.Dev{1} '.Chan' int2str(i)];
    invoke(TDT.RP, TDT.call_SetTag, tagName, Parameters.Chan(i));
    
    tagName = [TDT.Dev{1} '.sSortCode' int2str(i)];
    invoke(TDT.RP, TDT.call_SetTag, tagName, Parameters.SortCode(i));
    
    tagName = [TDT.Dev{1} '.sThresh' int2str(i)];
    invoke(TDT.RP, TDT.call_SetTag, tagName, Parameters.Thresh(i));
    
    tagName = [TDT.Dev{1} '.sCoef' int2str(i)];
    invoke(TDT.RP, TDT.call_WriteTag, tagName, Parameters.SortCoef(i));
    
end