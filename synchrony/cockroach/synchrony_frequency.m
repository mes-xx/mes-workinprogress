% This script makes plots analyzes the frequency content of the synchrony
% signals using wavelet analysis. One might expect the synchrony to have a
% frequency similar to the LFP. 

close all
clear all

% Set these parameters
datafile = 'results_20080831_111914.mat';

% Don't touch anything below here.

load(datafile)

total_neurons = size(spikes,2);
total_bins = size(syncs,3);
total_points = size(bootstrapped,3) * size(bootstrapped,4);
limit_high_index = round(limit_percentile * total_points);
limit_low_index  = round( (1-limit_percentile) * total_points);

% make vector of behaviors
timestamps = reshape(data(:,11:14), 1, []);
ind = round(timestamps / dt); %convert time to index in vector
ind = ind( ~isnan(ind) ); %only uses indices that are not nan
steps_per_bin = windowSize / dt;
behavior = zeros(endStep,1); %initialize empty behavior vector
behavior(ind) = 1; %set behavior vector to 1 wherever behaviror was recorded

% reduce behavior to bins
behavior = max(reshape( ...
    behavior(1:(length(behavior)-mod(length(behavior),steps_per_bin))), ...
    steps_per_bin, []));

fh = figure;

% for each pair of neurons
for neuron1 = 1:total_neurons
    for neuron2 = (neuron1+1):total_neurons
        

        sig = squeeze(syncs(neuron1,neuron2,:));
        stem(2*limit_high*behavior)
        title([int2str(neuron1) ' vs ' int2str(neuron2)])
        pause
        hold off
        
    end
end

