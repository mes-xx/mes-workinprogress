% soundtransform shows how brain signals are transformed into sound

% according to Syka et al. (1996) says that pigmented rats can discriminate
% a 7.3% difference in frequency and a 8.1 dB difference in intensity
% (worst case)

% They tested from 0.5 to 64 kHz and up to 50 dB above hearing threshold

clear all
close all

lfpspace = linspace(-10,10); %uV
syncspace = linspace(-1,1); %correlation coefs

logfreqspace = linspace( log(0.5), log(64) );
freqspace = exp(logfreqspace);

%logampspace = linspace( log(10), log(50) );
ampspace = linspace(10,50);

% LFP to frequency
figure
semilogy(lfpspace, freqspace)
title('LFP to Sound Frequency')
xlabel('LFP amplitude (\muV)')
ylabel('Sound Frequency (kHz)')

% Synchrony to amplitude
figure
plot(syncspace, ampspace)
title('Synchrony to Sound Amplitude')
xlabel('Synchrony')
ylabel('Sound Amplitude (dB)')
ylim([0 60])

% Similarity to 2D center-out task
figure
targamp = [30 30 50 50];
targfreq = [1.5 10 1.5 10];
centeramp = 40;
centerfreq = 4;
hold all
scatter(targamp, targfreq)
scatter(centeramp, centerfreq)
xlabel('Amplitude (dB)')
ylabel('Frequency (kHz)')