function [syncs] = cps5( spikes, triangleWidth, binSize, stepSize )
% CPS5 Calculates the syncrony in bins
% [syncs] = cps5( spikes, triangleWidth, binSize, stepSize )
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
%
% This is the same as cps4() except it takes the covariance of each pair of
% spikes individually.
if nargin == 4
    % stepSize was specified, so use it to convert triangleWidth and
    % binSize into numbers of time steps
    triangleSteps = triangleWidth / stepSize;
    binSteps = binSize / stepSize;
else
    triangleSteps = triangleWidth;
    binSteps = binSize;
end

nBins = floor(size(spikes,1)/binSteps);

%% make the triangle
if ~mod(triangleSteps, 2) % Make sure that the triangle has an odd number of steps
    triangleSteps = triangleSteps + 1;
end
step = 1 / (triangleSteps/2 + 0.5);
triangle = [step:step:1 (1-step):-step:step];

%% Separate out spikes

% find all the spikes
[sprows spcols] = find(spikes);
spind1 = sprows(spcols==1);
spind2 = sprows(spcols==2); 


%% Calculate synchrony

% for each bin
for bin = 1:nBins
    
    % the numbers for all the rows in this bin
    binRows = (bin-1)*binSteps + 1:binSteps;
    
    % check to make sure we have at least one pair of spikes in this bin.
    % if not, then set the synchrony to zero and skip to the next bin.
    if ~any(spind1(binRows)) || ~any(spind2(binRows))
        syncs(bin) = 0;
        continue;
    end
        
    % if we have gotten this far, then we have at least one spike in each
    % train for this bin.
    for sp1 = 
        
        
% Make new spike trains with one spike in each train
% Convolve new trains with triangle
% take covariance
% store value for later
% combine stored results  to get one sync measure for the  bin
% store sync measure for this bin to be returned later

end


% %% convolve triangle with spike trains
% trianglyWave = zeros( size(spikes,1) + length(triangle) - 1, size(spikes,2));
% 
% for nTrain = 1:size(spikes,2)
%     % for each spike train
%     
%     trianglyWave(:,nTrain) = conv(spikes(:,nTrain), triangle); 
% end
% 
% %% take covariance in steps
% 
% syncs = nan(size(spikes,2),size(spikes,2),nBins);
% 

% 
% %% Combine spike trains again