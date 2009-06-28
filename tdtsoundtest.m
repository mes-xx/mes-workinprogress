% tdtsoundtest tests the sound output on Michael's rat circuits
% The test plays a solid tone for 2 seconds, then plays pips of varying
% frequency and amplitude for ?? seconds.

freq_list = linspace(log(40),log(10e3),11);
amp_list  = linspace(log(0.5), log(1), 10);

disp('Initializing...')
InitializeDSP_Rats % runs script to initialize TDT variables
% Begin by turning everything off
TDT_set(TDT,'CursorAmp',0)
TDT_set(TDT,'CursorFreq',0)
TDT_set(TDT,'TargetAmp',0)
TDT_set(TDT,'TargetFreq',0)
TDT_set(TDT,'EnablePips',0)

disp('Playing 1000 Hz tone.')
% Turn on target, no pips!
TDT_set(TDT,'TargetFreq',log(1000))
TDT_set(TDT,'TargetAmp',1)
pause(1)

disp('Setting up for pips. You should still hear only single tone.')
% Set the cursor
TDT_set(TDT,'CursorFreq',log(500))
TDT_set(TDT,'CursorAmp',1)
pause(1)

disp('Enabling pips. You should now hear two sounds switching back and forth.')
% Enable the pips
TDT_set(TDT,'EnablePips',1)
pause(1)

disp('Cycling through frequencies. Pitch should rise and then fall.')
% Loop thru frequencies
for f = 2:length(freq_list)
    TDT_set(TDT,'CursorFreq',freq_list(n))
    pause(0.2)
end
for n = length(freq_list):-1:1
    TDT_set(TDT,'CursorFreq',freq_list(n))
    pause(0.2)
end
TDT_set(TDT,'CursorFreq',log(500))

disp('Cycling through amplitudes. Sound should get louder then quieter')
for n = 1:length(amp_list)
    TDT_set(TDT,'CursorAmp',amp_list(n))
    pause(0.2)
end
for n = length(amp_list):-1:1
    TDT_set(TDT,'CursorAmp',amp_list(n))
    pause(0.2)
end

disp('Turning off everything.')
TDT_set(TDT,'CursorAmp',0)
TDT_set(TDT,'TargetAmp',0)