clear all
close all

rates = [30 30];
nSync = 2000;
trainLength = 200;
stepSize = 0.001;
offset = 0;

spikes = [ makeSpikeTrains3( rates, nSync, trainLength, stepSize, offset ); ...
    makeSpikeTrains3( rates, 0, trainLength, stepSize, offset ); ...
    makeSpikeTrains3( rates, nSync, trainLength, stepSize, offset ) ];

h = stepSize;
Delta = 0.005;
Tau = 1.000;
S_alpha = 3;

ue = unitaryEvents(spikes, h, Delta, Tau, S_alpha);

stem(ue)