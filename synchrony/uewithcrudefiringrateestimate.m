%UEWITHCRUDEFIRINGRATEESTIMATE finds the variability of unitary event
%method when the firing rate is estimated over small (90 ms) windows. I was
%motivated to do this because the "cps" or "convolution-covariance" method
%is VERY VERY variable, but it does average out to a reasonable value. I
%think this should average out to a reasonable value too because the crude
%estimate of firing rate will average out to the proper value over time.
%Hopefully, the "cps" or "convolution-covariance" method will be less
%variable.

clear all
close all

% parameters for making spike trains
rates = [30 30];
trainLength = 600; %seconds
nSync = 10*trainLength; %10 synchronous spikes per second
stepSize = 0.001; %one millisecond precision
offset = 0.002; %two millisecond jitter

% parameters for cps
triangleWidth = (2*1.5*(offset+stepSize/2)); %seconds
binSize = 0.1; %100 millisecond chunks

% parameters for ue
h = stepSize;
Delta = 0.005; %look for synchronous spikes in 5 millisecond bins
Tau = binSize;
S_alpha = 3; %significance level for unitary events

% make some spike trains
spikes = makeSpikeTrains3(rates,nSync,trainLength,stepSize,offset);

% analyze with cps
temp = cps4( spikes, triangleWidth, binSize, binSize , stepSize );
cps_results = squeeze(temp(1,2,:));

% analyze with ue
ue_results = unitaryEvents2(spikes,h,Delta,Tau,S_alpha);

% calculate coefficients of variation
cps_cv = std(cps_results) / mean(cps_results)
ue_cv  = std(ue_results)  / mean(ue_results)

% plot the distributions of values for each measurement
figure
hist(cps_results)
figure
hist(ue_results)

