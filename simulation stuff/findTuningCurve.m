function [b,bint,r,rint,stats] = findTuningCurve(firingRates, movementDirections)
%FINDTUNINGCURVE Finds tuning curve for a single neuron
%   [b,bint,r,rint,stats] = findTuningCurve(firingRates,
%   movementDirections). firingRates is a column vector of binned firing
%   rates, where each element is the number of spikes in one bin.
%   movementDirections is a matrix where each row is the movement vector at
%   a bin (same bins as for firingRates). The number of columns in
%   movementDirections is equal to the number of dimensions in which
%   movements are made. This function returns the same stuff as MATLAB's
%   native regress() function (see help regress for more info). b(1) is the
%   baseline firing rate. b(2) is the parameter determining speed tuning.
%   b(3:end) are the directional tuning parameters.

% Make sure firingRates are a column vector
if size(firingRates,2) > 1
    error('firingRates must be a column vector.');
end

% Make sure movementDirections has the proper dimensions. Should have the
% same number of rows as firingRates.
if size(movementDirections,1) ~= size(firingRates,1)
    error('movementDirections and firingRates must have the same number of rows.');
end

speeds = sqrt(sum(movementDirections.^2,2));

[b,bint,r,rint,stats] = regress(firingRates, [ones(length(speeds),1), movementDirections]);

1;