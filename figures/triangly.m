function [ wave ] = triangly( spikes )
%TRIANGLY Summary of this function goes here
%   Detailed explanation goes here

twidthS = 0.0105; %seconds
stepSize = 0.001/278;

twidth = twidthS / stepSize;

step = 1/twidth;

triangle = [step:step:1 (1-step):-step:step];

%figure
hold all

dy = 0.5;
for n = 1:size(spikes,2)
    temp = conv(triangle,spikes(:,n));
    wave(:,n) = temp(round(length(triangle)/2):end);
    plot(wave(:,n)+dy,'-r','LineWidth',4)
    dy = dy+2;
end

keyboard %%%DEBUG
