function [ spikeTrains ] = makeSpikeTrains( rates, synchrony )
%MAKESPIKETRAINS Makes spike trains with synchrony
%   spikeTrains = makeSpikeTrains(rates, synchrony) returns two spike
%   trains as the columns of spikeTrains. For each train, the rows
%   represent time steps and each value is 1 if a spike occurred in that
%   time step and 0 otherwise.
%
%   rates is a 2 element array that specifies the firing rates of the two
%   simulated neurons in Hertz. rates should be sorted so that the lower
%   firing rate is first.
%
%   synchrony is the probability that a spike in one neuron causes a spike
%   in the other. The value must be between 0 and 1.
%
%   The length of the spike trains is 600 seconds, the step size is 1
%   millisecond, and synchronous spikes occur at exactly the same time (no
%   offset).

%% Error checking
if numel(rates) ~= 2
    error('First argument to makeSpikeTrains needs to be a list of exactly two firing rates')
end

if numel(synchrony) ~= 1
    error('Second argument to makeSpikeTrains needs to a scalar value of synchrony between the two spike trains')
end

if (synchrony > 1) || (synchrony < 0)
    error('Second argument to makeSpikeTrains must be between 0 and 1')
end

%% Initialize variables
rates = sort(rates); % make sure lowest rate is first
rates(2) = rates(2) - (synchrony .* rates(1)); % compensate for synchrony
trainLength = 600; %seconds
stepSize = 0.001; %seconds
nSteps = floor(trainLength ./ stepSize);
nSpikes = floor(rates .* trainLength);
offset = 0.002; %seconds
offsetSteps = round(offset/stepSize);


%% Make randomly distributed spike trains
spikeIndices = cell(2,1);
spikeTrains = zeros(nSteps, 2);
for ii = 1:numel(rates)
    ind = randperm(nSteps);
    spikeIndices{ii} = ind(1:nSpikes(ii));

    spikeTrains(spikeIndices{ii},ii) = 1;
end

%% Add in synchrony

nSync = 0;
totalSync = floor(synchrony * nSpikes(1));

while nSync < totalSync
    
    ind = randperm( length(spikeIndices{1}) );
    syncIndices = spikeIndices{1}(ind(1:(totalSync-nSync))) + offsetSteps;
    
    uniques = setdiff( syncIndices, spikeIndices{2} );
    
    nSync = nSync + length(uniques);
    
    spikeIndices{2} = [spikeIndices{2} uniques];
    spikeTrains(uniques,2) = 1;
    
end