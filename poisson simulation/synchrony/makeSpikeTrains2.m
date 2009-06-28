function [ spikeTrains ] = makeSpikeTrains2( rates, nSync )
%MAKESPIKETRAINS Makes spike trains with synchrony
%   spikeTrains = makeSpikeTrains(rates, nSync) returns two spike
%   trains as the columns of spikeTrains. For each train, the rows
%   represent time steps and each value is 1 if a spike occurred in that
%   time step and 0 otherwise.
%
%   rates is a 2 element array that specifies the firing rates of the two
%   simulated neurons in Hertz. rates should be sorted so that the lower
%   firing rate is first.
%
%   nSync is the number of synchronous spikes on top of what would be
%   expected by chance. This should be less than or equal to the number of
%   spikes specified by the firing rate
%
%   The length of the spike trains is 600 seconds, the step size is 1
%   millisecond, and synchronous spikes occur at exactly the same time (no
%   offset).

trainLength = 600; %seconds

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
stepSize = 0.001; %seconds
nSteps = floor(trainLength ./ stepSize);
nSpikes = floor(rates .* trainLength);
nSpikes(2) = nSpikes(2) - nSync;% compensate for synchrony

%% Make randomly distributed spike trains
spikeIndices = cell(2,1);
spikeTrains = zeros(nSteps, 2);
for ii = 1:numel(rates)
    ind = randperm(nSteps);
    spikeIndices{ii} = ind(1:nSpikes(ii));

    spikeTrains(spikeIndices{ii},ii) = 1;
end

%% Add in synchrony

iSync = 0;

while iSync < nSync
    
    ind = randperm( length(spikeIndices{1}) );

    syncIndices = spikeIndices{1}(ind(1:(nSync-iSync)));
    
    uniques = setdiff( syncIndices, spikeIndices{2} );
    
    iSync = iSync + length(uniques);
    
    spikeIndices{2} = [spikeIndices{2} uniques];
    spikeTrains(uniques,2) = 1;
    
end