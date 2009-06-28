harmonics = [1, 4]; % pick the harmonics you want to hear
basefreq = 2000; %Hz, the base frequency
amprange = [1 1]; %range of amplitudes
len = 2; %seconds

freq = basefreq*harmonics;

amp = linspace(amprange(1), amprange(2), numel(freq));

s = mySound(freq,amp,len);

sound(s, 44e3)