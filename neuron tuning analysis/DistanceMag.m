function [ r ] = DistanceMag( p1, p2 )
%DISTANCEMAG Summary of this function goes here
%   Detailed explanation goes here

r = sqrt(sum( (p1-p2).^2, 2 ));