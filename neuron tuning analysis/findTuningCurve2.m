function [b,bint,r,rint,stats] = findTuningCurve2(firingRates, velocity)
%FINDTUNINGCURVE Finds tuning curve for multiple neurons
%   [b,bint,r,rint,stats] = findTuningCurve(firingRates,
%   velocity). firingRates is a matrix of binned firing
%   rates, where each element is the number of spikes in one bin. Each
%   column represents one neuron, and each row one timestep.
%   velocity is a matrix where each row is the movement vector at
%   a bin (same bins as for firingRates). The number of columns in
%   velocity is equal to the number of dimensions in which
%   movements are made. This function returns the same stuff as MATLAB's
%   native regress() function (see help regress for more info), but in cell
%   array form where each cell containts data for one neuron.


% Make sure movementDirections has the proper dimensions. Should have the
% same number of rows as firingRates.
if size(velocity,1) ~= size(firingRates,1)
    error('velocity and firingRates must have the same number of rows.');
end

speeds = sqrt(sum(velocity.^2,2));
directions = normalize(velocity);

for j = 1:size(firingRates,2) % for each neuron...
    
    % Do the regression for a single neuron
    [b_1N,bint_1N,r_1N,rint_1N,stats_1N] = regress(firingRates(:,j), [ones(size(speeds)), speeds, velocity]);
    
    % Add the results from single neuron to the giant matrix of results.
    % All of the stuff from the jth neuron will be in the jth column.
    b     {j} = b_1N;
    bint  {j} = bint_1N;
    r     {j} = r_1N;
    rint  {j} = rint_1N;
    stats {j} = stats_1N;
    
end % j