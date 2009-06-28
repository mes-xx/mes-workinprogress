function [ spikeTrains ] = makeSpikeTrains5( rates, nSync, trainLength, ...
                                    stepSize, offset, intervalLength )
%MAKESPIKETRAINS Makes spike trains with synchrony
%   spikeTrains = makeSpikeTrains(rates, nSync) returns two spike
%   trains as the columns of spikeTrains. For each train, the rows
%   represent time steps and each value is 1 if a spike occurred in that
%   time step and 0 otherwise. This is the same as makeSpikeTrains2 except
%   it lets you specify things other than rates and nSync.
%
%   rates is a 2 element array that specifies the firing rates of the two
%   simulated neurons in Hertz. rates should be sorted so that the lower
%   firing rate is first.
%
%   nSync is the number of synchronous spikes on top of what would be
%   expected by chance. This should be less than or equal to the number of
%   spikes specified by the firing rate
%
%   trainLength is the length of the spike trains in seconds
%
%   stepSize is the length of each time step in seconds
%
%   offset is the difference in time between "synchronous" spikes, in
%   seconds
%
% This is the same as makeSpikeTrains3 except it makes the trains one bit
% at time instead of all at once

%% Error checking
if numel(rates) ~= 2
    error('First argument to makeSpikeTrains needs to be a list of exactly two firing rates')
end

if numel(nSync) ~= 1
    error('Second argument to makeSpikeTrains needs to a scalar value for the number of synchronous spikes')
end

if nSync > (min(rates)*trainLength)
    error('Too many synchronous spikes! The neurons are not firing that quickly.')
end

%% Initialize variables
rates = sort(rates); % make sure lowest rate is first
nSteps = floor(trainLength ./ stepSize);
nSpikes = floor(rates .* trainLength);
nSpikes(2) = nSpikes(2) - nSync;% compensate for synchrony
offsetSteps = floor(offset ./ stepSize);

%% Make randomly distributed spike trains
% Instead of making it all at once, break it up into one second long intervals and pass
% each part to makeSpikeTrains3 for the actual randomizing

spikeTrains = [];

nIntervals = floor(trainLength/intervalLength);
for interval = 0:nIntervals-1
    
    
    nSync_temp = nSync*intervalLength/trainLength;
    spikes_temp = makeSpikeTrains3(rates, nSync_temp, intervalLength, stepSize, offset );
    spikeTrains = [spikeTrains; spikes_temp];
    
end

% the last interval may not be a full second long, so calculate the length
intervalLength = trainLength-nIntervals;
nSync_temp = nSync*intervalLength/trainLength;
spikes_temp = makeSpikeTrains3(rates, nSync_temp, intervalLength, stepSize, offset );
spikeTrains = [spikeTrains; spikes_temp];