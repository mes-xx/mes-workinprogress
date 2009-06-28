% lfpcpsbciexample makes example sounds for 2D bci control with LFP and cps

T_trial = 3; %seconds, total length of example
dt = 1/44e3; %seconds, time step

noise.amp = 15;

lfp.amp_on = 30;
lfp.amp_off = 10;
lfp.freq = 30; %Hz

spike.amp = 80;
spike.freq = 1e3; %Hz
spike.rate = [20 30]; %Hz
spike.sync = 10*2*T_trial/3; %spikes, total number of synchronous spikes
spike.jitter = 0.005; %seconds


t = 0:dt:T_trial;
midpoint = floor(length(t)/2);
randSeed = rand('seed'); % store random number generator seed
%% Raw extracellular recordings

% start with gaussian white noise for the background
sound.noise = randn(size(t));

%%%DEBUG
% Verify that noise is white
plot(abs(fftshift(fft(sound.noise))))
%%%

% Generate LFP oscillation
sound.lfp = sin(2*pi*lfp.freq*t);
sound.lfp(1:midpoint) = lfp(1:midpoint)*lfp.amp_off; % use amp_off for first half
sound.lfp(midpoint:end) = lfp(midpoint:end)*lfp.amp_on; % use amp_on for 2nd half

% Generate spikes
strobe = makeSpikeTrains3(spike.rate, spike.sync, T_trial-1/spike.freq, dt, spike.jitter);
% strobe signal is high for one timestep at the beginning of each spike.
% convolve the strobe with the waveform of a single spike to get spike
% signal
sound.spikes = conv( strobe, sin( linspace(0,2*pi,1/spike.freq/dt) ) );

sound.raw = sound.noise + sound.lfp + sound.spikes;

%% Take LFP and synchrony measurements

% do fft to get power spectrum
Fs = 1000;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = 1000;                     % Length of signal
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t); 
y = x + 2*randn(size(t));     % Sinusoids plus noise
plot(Fs*t(1:50),y(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('time (milliseconds)')

% get power in lfp band

% do cps