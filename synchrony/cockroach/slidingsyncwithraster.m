%slidingsyncwithraster Computes synchrony using a sliding window and plots it with spike rasters

% uncomment this to add my toolbox directory to the matlab path. only need
% to do this when running on the cluster:
addpath(genpath('/home/mes41/toolbox/'))

debugdisp('Beginning slidingsyncwithraster.m')

clear all

%%

% load data from file
% --> must include spikes, dt, endTime
load spiketrains
% load('datatemp')
debugdisp('Loaded data from file. Initializing other variables.')
n_units = size(spikes, 2); %number of units (neurons)


windowSize = 0.1; %seconds
windowStep = 1/400; %seconds
windowSamples = floor(windowSize/dt); %number of samples in each window
windowStepSamples = floor(windowStep/dt); %number of samples to slide the window
windowSize = windowSamples*dt; %redefine windowSize so that it contains an integer number of samples
windowStep = windowStepSamples*dt; %redefine windowSize so that it contains an integer number of samples
t_sync = 0:windowStep:(endTime-windowSize);
t_sync = t_sync(1:end-1);% fix off by one error
t_spike = 0:dt:endTime;
n_windows = length(t_sync);

triangleWidth = 0.011; %seconds
percentile = 0.01; % used to determine what is significant based on bootstrapping
total_reps = 50;

% this makes a mapping from a pair of neurons onto a single index. using
% this, i can save a lot of space in my bootstrapping matrix
ind = 0;
indmap = zeros(n_units);
for n1 = 1:n_units
    for n2 = (n1+1):n_units
        ind = ind+1;
        indmap(n1,n2) = ind;
        indmap(n2,n1) = ind;
    end
end
clear ind n1 n2


significant_high = nan(n_units,n_units);
significant_low = nan(n_units,n_units);

debugdisp('Done initializing. Computing synchrony.')

%%

% compute synchrony
syncs = cps_sw(spikes, triangleWidth, windowSize, windowStep, dt);
n_windows = size(syncs,3);

debugdisp('Calculated synchrony. Beginning bootstrapping.')

% shuffle and recompute synchrony for bootstrapping

bootstrapped = nan( max(max(indmap)), size(syncs,3)*total_reps );

colstart = 1;
for rep = 1:total_reps
    newSpikes = shuffleBins(spikes, windowSize/dt);
    temp = cps_sw(newSpikes, triangleWidth, windowSize, windowStep, dt);
    colend = colstart+n_windows-1;
    for n1 = 1:n_units
        for n2 = (n1+1):n_units
            row = indmap(n1,n2);
            bootstrapped(row,colstart:colend) = temp(n1,n2,:);
        end
    end
    colstart = colend+1;
    debugdisp(['Done with bootrapping repetition ' int2str(rep)])
end
clear colstart newSpikes temp colend n1 n2 row    


% calculate significant levels
debugdisp('Done with bootstrapping. Calculating significant levels.')
N = size(bootstrapped,2); %number of values
for n1 = 1:n_units
    for n2 = (n1+1):n_units
        high_index = round(percentile*N);
        low_index = round((1-percentile)*N);
        row = indmap(n1,n2);
        values = sort(bootstrapped(row,:));
        significant_high(n1,n2) = values(high_index);
        significant_low(n1,n2) = values(low_index);
    end
end
clear bootstrapped values n1 n2 row

% save results
filename = sprintf('results_%d%02d%02d_%02d%02d%02.0f',clock);
save(filename)