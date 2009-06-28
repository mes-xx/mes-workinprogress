function [s] = mySound( freq, amp, len )
% mySound creates mixed tones with sampling frequency of 44 kHz
% s = mySound(freq,amp,len)
% s = sound waveform, play with MATLAB's built in sound function, like
%     this (note the sampling frequency): sound(s, 44e3)
% freq = frequencies of the tones, in Hz. For each element in freq, a
%        sinusoid with that frequency will be added to the sound. If freq
%        is just a single number, then the sound will be a pure tone
% amp = amplitude of the sinusoids. The size of this array should either
%       match the size of freq or just be a single number. If it matches
%       the size of freq, then then the amplitudes are matched up with each
%       sinusoid (duh!). If there is just one value in amp, then all
%       sinusoids get the same amplitude. The units on amplitude are
%       arbitrary, I think.
% len = length of sound, in seconds

samplingFreq = 44e3; %Hz

t = 0:1/samplingFreq:len; % time, sampled at the sampling frequency

s = zeros(size(t)); % initialize empty sound

% calcualte the angular frequencies
w = 2*pi*freq;
    
% if there is just one amplitude, use it for all frequencies
if numel(amp) == 1
    newamp = zeros(size(freq));
    newamp(:) = amp;
    amp = newamp;
end

for n = 1:numel(freq) % for each frequency
        
    % add the sinusoid to the sound
    s = s + amp(n) * sin( w(n) * t );
end