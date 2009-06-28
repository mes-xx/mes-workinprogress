function [ synchrony ] = cps( spikeTrains, triangleWidth )
%CPS Calculates the syncrony between spike trains using cummulative product sum method
%   Detailed explanation goes here 

%% Initialize variables

stepSize = 0.001; %seconds
triangleSteps = triangleWidth ./ stepSize; %triangle width in time steps

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


%%%DEBUG
keyboard 

% trianglyWave( trianglyWave>1 ) = 1; %cap values at 1

%% Covariance


variances = cov(trianglyWave);
synchrony = variances(1,2);
% var1 = variances(1,1);
% var2 = variances(2,2);

%synchrony = synchrony / mean([var1 var2]);