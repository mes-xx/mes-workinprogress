function [syncs] = cps_sw( spikes, triangleWidth, binSize, binShift, stepSize )
% CPS4 Calculates the syncrony in bins
% [syncs] = cps4( spikes, triangleWidth, binSize, stepSize )
%   syncs = synchrony measured at each time bin
%   spikes = spike trains, with each row as one time step and each column
%   as one neuron. can use more than 2 neurons
%   triangleWidth = width (see stepSize for units) of triangle
%   binSize = size of each bin (see stepSize for units) of bins over which
%   synchrony is calculated
%   stepSize = optional parameter that gives the length of each time step
%   (each row in spikes). If this is specified, then triangleWidth and
%   binSize must be in the same units. If omitted, then triangleWidth and
%   binSize must be a number of time steps.


if nargin == 5
    % stepSize was specified, so use it to convert triangleWidth and
    % binSize into numbers of time steps
    triangleSteps = triangleWidth / stepSize;
    binSteps = floor(binSize / stepSize);
    shiftSteps = floor(binShift / stepSize);
else
    triangleSteps = triangleWidth;
    binSteps = binSize;
    shiftSteps = binShift;
end

nBins = floor( (size(spikes,1)-binSteps) / shiftSteps);

%% make the triangle
if ~mod(triangleSteps, 2) % Make sure that the triangle has an odd number of steps
    triangleSteps = triangleSteps + 1;
end
step = 1 / (triangleSteps/2 + 0.5);
triangle = [step:step:1 (1-step):-step:step];

%% convolve triangle with spike trains
trianglyWave = zeros( size(spikes,1) + length(triangle) - 1, size(spikes,2));

for nTrain = 1:size(spikes,2)
    % for each spike train
    
    trianglyWave(:,nTrain) = conv(spikes(:,nTrain), triangle); 

end

%% take covariance in steps

syncs = nan(size(spikes,2),size(spikes,2),nBins);
try
for bin = 1:nBins
    rows = (1:binSteps) + (bin-1)*shiftSteps;
    syncs(:,:,bin) = cov(trianglyWave(rows,:));
end
catch
    keyboard
end
