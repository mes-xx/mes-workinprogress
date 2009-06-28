function [ delayed ] = delayRows( matrix, delay )
%DELAYARRAY Delays array
%   delayArray(matrix, delay) returns a matrix the same size as input
%   matrix, with some NaN's at the beginning 1:delay rows.

% Get the size of the input matrix
[rows cols] = size(matrix);

% add the proper number of NaNs to the beginning to make the delay
delayed = [ nan(delay, cols); matrix ];
% Use NaN's instead of zeros because we don't know what the value of array
% should be outside of the given values

% Crop delayed matrix to same size as input. Remove rows from the end.
delayed = delayed(1:rows,:);
