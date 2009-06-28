function [ spikeTrains ] = makeSpikeTrains3( rates, nSync, trainLength, ...
                                    stepSize, offset )
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

    syncIndices = spikeIndices{1}(ind(1:(nSync-iSync))) + offsetSteps.*round((2*rand(1,nSync-iSync)-1)*offsetSteps);
    

    
    % make sure indices are within the train (the offset might make them be
    % too big or too small)
    syncIndices( syncIndices < 1 ) = 1;
    syncIndices( syncIndices > size(spikeTrains,1) ) = size(spikeTrains,1);
    
    uniques = setdiff( syncIndices, spikeIndices{2} );
    
    iSync = iSync + length(uniques);
try    
    spikeIndices{2} = [spikeIndices{2} uniques];
    spikeTrains(uniques,2) = 1;
catch
    keyboard
end
end