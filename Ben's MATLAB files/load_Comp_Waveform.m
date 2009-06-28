%This script loads the waveform which compensates for the effects of
%stimulation.  It is designed to work with 'comp_waveforms.mat', which has
%been acquired recently using the same pulse width and amplitude as during
%acquisition

TDT.use_TDevAcc=1;

Init_ActX; % the generic function that initializes the actx connection

test_length=100; % number of samples to average

TDT.num_chan=16; % number of channels being recorded in OpenEx

TDT.tag_CompEnab=[TDT.Dev{1} '.CompEnab'];

TDT.tag_CompBuf=[TDT.Dev{1} '.CompBuf'];

for j=1:TDT.num_chan,   %fills comp_waveforms with the baselines for stimulation
        
    invoke(TDT.RP, TDT.call_WriteTag, [TDT.tag_CompBuf int2str(j)], 0, (comp_waveforms(j,:)) );
        
end;

invoke(TDT.RP, TDT.call_SetTag, TDT.tag_CompEnab, -1);   %allows the compensation to occur once the data have been uploaded

Close_ActX; % common function used to close an open actX connection