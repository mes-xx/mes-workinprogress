function y = sigmoid( x, ymin, ymax )
%SIGMOID Summary of this function goes here
%   Detailed explanation goes here

n = numel(x); %number of points

t = linspace(-6,6,n);

y = (ymax-ymin) ./ (1 + exp(-t)) + ymin;
