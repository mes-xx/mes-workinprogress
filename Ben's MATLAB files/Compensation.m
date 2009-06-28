%This script acquires the waveform which compensates for the effects of
%stimulation.  It is designed to work with 'comp_waveform_acquire.rco' and
%the associated openEX project files

TDT.use_TDevAcc=1;

Init_ActX; % the generic function that initializes the actx connection

test_length=100; % number of samples to average

TDT.num_chan=16; % number of channels being recorded in OpenEx

TDT.tag_CompBuf=[TDT.Dev{1} '.CompBuf'];

TDT.tag_CompEnab=[TDT.Dev{1} '.CompEnab'];

TDT.tag_CompWrite=[TDT.Dev{1} '.ReadWrite'];

TDT.tag_CompIndex=[TDT.Dev{1} '.SerIndex1'];

TDT.tag_CompBufEnab=[TDT.Dev{1} '.CompBufEnab'];

%fills comp_waveforms with the baselines for stimulation
comp_waveforms = zeros(TDT.num_chan,1005);

invoke(TDT.RP, TDT.call_SetTag, TDT.tag_CompWrite, 1);
invoke(TDT.RP, TDT.call_SetTag, TDT.tag_CompBufEnab, 1);

CompIndex = -1;

for i=1:test_length,
    
    while(CompIndex~=999)  %determines whether the capture cycle has completed
        CompIndex=invoke(TDT.RP, TDT.call_GetTag, TDT.tag_CompIndex);
    end;
    
    for j=1:TDT.num_chan,   %fills comp_waveforms with the baselines for stimulation
        
        comp_waveforms(j,:) = comp_waveforms(j,:)+double(invoke(TDT.RP, TDT.call_ReadTag, [TDT.tag_CompBuf int2str(j)], 0, 1005));
        
    end;
    
    while(CompIndex==999)  %determines whether the capture cycle has completed
        CompIndex=invoke(TDT.RP, TDT.call_GetTag, TDT.tag_CompIndex);
    end;
    
    
end;

invoke(TDT.RP, TDT.call_SetTag, TDT.tag_CompBufEnab, 0);
invoke(TDT.RP, TDT.call_SetTag, TDT.tag_CompWrite, 0);  %sets the buffers to read, not write (to preserve the baselines data)

Waveforms = (comp_waveforms)/(test_length);

for j=1:TDT.num_chan,   %writes to the buffers
    invoke(TDT.RP, TDT.call_WriteTag, [TDT.tag_CompBuf int2str(j)], 0, single(Waveforms(j,:)));
end

invoke(TDT.RP, TDT.call_SetTag, TDT.tag_CompBufEnab, 1);

Close_ActX; % common function used to close an open actX connection
