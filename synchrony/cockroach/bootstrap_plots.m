% This script makes plots using the bootstrapping data generated by main.m
% First it find the  95 percentile of the shuffled data and then shows the
% original data compared to the 95 percentile. Anything above the 95th
% percentile we can say is above what we could expect by chance 95% of the
% time.

close all
clear all

% Set these parameters
datafile = 'results_20080831_111914.mat';
limit_percentile = 0.95;
% Don't touch anything below here.

load(datafile)

total_neurons = size(spikes,2);
total_bins = size(syncs,3);
total_points = size(bootstrapped,3) * size(bootstrapped,4);
limit_high_index = round(limit_percentile * total_points);
limit_low_index  = round( (1-limit_percentile) * total_points);

fh = figure;

% for each pair of neurons
for neuron1 = 1:total_neurons
    for neuron2 = (neuron1+1):total_neurons
        
        % lump all data from this pair of neurons together
        lumped = reshape(bootstrapped(neuron1,neuron2,:,:),1,[]);
        
        % find the 95 percentile
        lumped = sort(lumped);
        limit_high = lumped(limit_high_index);
        limit_low  = lumped(limit_low_index);
        
        % plot the limit and the actual data
        plot(ones(1,total_bins)*limit_high)
        hold all
        plot(ones(1,total_bins)*limit_low)
        plot(squeeze(syncs(neuron1,neuron2,:)))
        title([int2str(neuron1) ' vs ' int2str(neuron2)])
        pause
        hold off
        
    end
end