close all
clear all

% Load data (saved from cpsrateindependent4.m)
load('C:\research\code\matlab\synchrony\results_20090112_153005.mat')

% pick one firing rate to stay stationary
i_rate1 = 5;

% set the number  of bins for the histograms
n_bins = 50;

% choose synchrony value
i_sync = 4;

% find centers of bins. they should be evenly spaced between the absolute
% max and absolute min of sync values
binmax = max(max(max(max(synchrony))));
binmin = min(min(min(min(synchrony))));
bincenters = linspace(binmin,binmax,n_bins);

% use hist to make histograms. these graphs will flash by very quickly, but
% don't worry. we will make a graph at the end that includes all the info
for i_rate2 = 1:length(rates)
    Y = squeeze(synchrony(i_sync,i_rate1,i_rate2,:));
    figure(1) % this forces the histogram onto fig 1. just ignore it.
    z = hist(Y,bincenters);
    z = (z - min(z))/(max(z)-min(z)); %normalize histogram!
    figure(2) % this is the plot you want! look at this!!!
    hold on
    x = bincenters;
    y = i_rate2*ones(size(z));
    plot3(x,y,z)
    hold off
end
