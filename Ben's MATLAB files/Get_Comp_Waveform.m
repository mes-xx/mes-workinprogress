%This script acquires the waveform which compensates for the effects of
%stimulation.  It is designed to work with 'comp_waveform_acquire.rco' and
%the associated openEX project files

TDT.use_TDevAcc=1;

Init_ActX; % the generic function that initializes the actx connection

test_length=100; % number of samples to average

TDT.num_chan=16; % number of channels being recorded in OpenEx

TDT.tag_getComp=[TDT.Dev{1} '.GetCompData'];

TDT.tag_resetComp=[TDT.Dev{1} '.ResetGetData']; 

TDT.tag_CompBuf=[TDT.Dev{1} '.CompBuf'];

for j=1:TDT.num_chan,   %fills comp_waveforms with the baselines for stimulation
        
    comp_waveforms(j,:) = zeros(1,1000);
        
end;

for i=1:test_length,
    
    go = 0;
    
    while(go == 0)  %determines whether the capture cycle has completed
        go = invoke(TDT.RP, TDT.call_GetTag, TDT.tag_getComp);
    end;
    
    for j=1:TDT.num_chan,   %fills comp_waveforms with the baselines for stimulation
        
        comp_waveforms(j,:) = comp_waveforms(j)+invoke(TDT.RP, TDT.call_ReadTag, [TDT.tag_CompBuf int2str(j)], 0, 1000);
        
    end;
    
    invoke(TDT.RP, TDT.call_SetTag, TDT.tag_resetComp, 1);  %sets the reset high for a few cycles to reset the output (connected to '.tag_GetComp') to 0
    invoke(TDT.RP, TDT.call_SetTag, TDT.tag_resetComp, 0);
    
end;

comp_waveforms./test_length;

save ('comp_waveforms', 'comp_waveforms');

Close_ActX; % common function used to close an open actX connection
