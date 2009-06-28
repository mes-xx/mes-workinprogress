function [ synchrony, newLeftovers ] = cps3( spikeTrains, triangleWidth, oldLeftovers )
%CPS Calculates the syncrony between spike trains using cummulative product sum method
%   [synchrony,leftovers] = cps3(spikeTrains,triangleWidth,leftovers)
%   This is just like the cps() function, except it accepts and returns a
%   leftovers vector that is used to get rid of the binning problem. This
%   version should be used instead of cps() when we are binning data
%   instead of evaluating the whole spike train at once.

%% Initialize variables

stepSize = 0.001; %seconds
triangleSteps = triangleWidth ./ stepSize; %triangle width in time steps

% If leftovers were not supplied, make leftovers zero
if nargin == 2
    oldLeftovers = [0 0];
end

%% Make the triangle

% Make sure that the triangle has an odd number of steps
if ~mod(triangleSteps, 2)
    triangleSteps = triangleSteps + 1;
end

step = 1 / (triangleSteps/2 + 0.5);

triangle = [step:step:1 (1-step):-step:step];

%% Convolve

trianglyWave = zeros( size(spikeTrains,1) + length(triangle) - 1, size(spikeTrains,2));

for nTrain = 1:size(spikeTrains,2)
    % for each spike train
    

    trianglyWave(:,nTrain) = conv(spikeTrains(:,nTrain), triangle); 
end

%% Deal with leftovers

% make old leftovers the proper size
oldLeftovers = [oldLeftovers; zeros(size(trianglyWave,1)-size(oldLeftovers,1),2)];

% add in the old leftovers
trianglyWave = trianglyWave + oldLeftovers;

% get the new leftovers
newLeftovers = trianglyWave((size(spikeTrains,1)+1):end,:);

% resize trianglyWave so that it doesn't include new leftovers
trianglyWave = trianglyWave(1:size(spikeTrains,1),:);

%% Covariance


variances = cov(trianglyWave);
synchrony = variances(1,2);
% var1 = variances(1,1);
% var2 = variances(2,2);

%synchrony = synchrony / mean([var1 var2]);