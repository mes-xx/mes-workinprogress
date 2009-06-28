function [ newsound ] = adsr( sound, attack_time, decay_time, peak_amp, sustain_amp, release_time, Fs )
%ADSR Summary of this function goes here
%   Detailed explanation goes here

% make the ramp up in amplitude from 0 to peak_amp during the attack
a = linspace(0,peak_amp,attack_time*Fs);

% make the decay from the peak amplitude to the sustain amplitude
d = linspace(peak_amp,sustain_amp,decay_time*Fs);

% make the release
r = linspace(sustain_amp,0,release_time*Fs);

sustain_steps = length(sound) - length(a) - length(d) - length(r);

% if the envelope is bigger than the sound, throw an exception
if sustain_steps < 0
    error('Sound is shorter than the envelope.')
end

% make a sustained amplitude for whatever time isnt used in the attack,
% decay, or release
s = ones(1,sustain_steps)*sustain_amp;

envelope = [ a d s r ];


    

newsound = envelope .* sound;