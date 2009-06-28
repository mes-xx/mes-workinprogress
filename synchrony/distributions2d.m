close all
clear all

% Load data (saved from cpsrateindependent4.m)
load('C:\research\code\matlab\synchrony\results_20090112_153005.mat')

% pick one firing rate to stay stationary
i_rate1 = 1;

% set the number  of bins for the histograms
n_bins = 50;

% choose synchrony value
%i_sync = 4;

% find centers of bins. they should be evenly spaced between the absolute
% max and absolute min of sync values
binmax = max(max(max(max(synchrony))));
binmin = min(min(min(min(synchrony))));
bincenters = linspace(binmin,binmax,n_bins);

colors = 'rbgcmyk'; %used to pick color for lines

% use hist to make histograms. these graphs will flash by very quickly, but
% don't worry. we will make a graph at the end that includes all the info
for i_sync = 1:length(sync)
    
    for i_rate2 = 1:length(rates)
        temp = squeeze(synchrony(i_sync,i_rate1,i_rate2,:));
        y(i_rate2) = mean(temp);
        stds(i_rate2) = std(temp);

    end
    
    figure(1)
    hold on
    plot(rates,y,['-', colors(i_sync)])
    plot(rates,y-stds,[':', colors(i_sync)])
    plot(rates,y+stds,[':', colors(i_sync)])
    hold off
end
