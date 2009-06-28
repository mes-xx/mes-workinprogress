close all
clear all

% time step (resolution of spike trains)
dt = 0.0002; %seconds

triangleWidth = 0.011; %seconds

windowSize = 0.1; %seconds

% number of times to shuffle data to get a "baseline" level
total_reps = 100;

%% load in the data that Dr. Ritzmann gave me
load('cockroach6-19-2008')


%% separate the data into variables with good names

% there are 10 units
timestamps = data(:,1:10);

% i'm not exactly sure what these are, but they have to do with the
% position of the cockroach's antennae
sim_lt  = data(:,11);
sim_rt  = data(:,12);
sim_in  = data(:,13);
sim_out = data(:,14);


return %%%DEBUG
disp([ sprintf('%d/%d/%d %d:%d:%.0f',clock) ' Data loaded.' ])


%% make spike trains

% initialize trains
endTime = max(max(timestamps));
endStep = ceil(endTime/dt);
spikes = zeros(endStep,size(timestamps,2));

% convert timestamps into time steps using the temporal resolution and make
% sure that timesteps are integers!
timesteps = round(timestamps / dt);

% finally, put the spikes where they belong
for col = 1:size(timesteps,2)
    rows = timesteps(:,col);
    rows = rows( ~isnan(rows) );
    spikes(rows,col) = 1;
end

%%%DEBUG
disp([ sprintf('%d/%d/%d %d:%d:%.0f',clock) ' Converted timestamps to spike trains.'])

%% calculate synchrony

syncs = cps4( spikes, triangleWidth, windowSize, dt );

%%%DEBUG

%% bootstrapping
% for comparison, shuffle the bins a couple times to get "chance levels"

% initialze variable to store all the results
bootstrapped = zeros([size(syncs) total_reps]);

for rep = 1:total_reps
    
    %%%DEBUG
    disp([sprintf('%d/%d/%d %d:%d:%.0f',clock) ' Beginning bootstrapping repetition ' int2str(rep)])
    
    % do the shuffle!
    newSpikes = shuffleBins(spikes, windowSize/dt);

    % Measure synchrony again
    bootstrapped(:,:,:,rep) = cps4( newSpikes, triangleWidth, windowSize, dt );
    
    %%%DEBUG
    disp([sprintf('%d/%d/%d %d:%d:%.0f',clock) ' Ending bootstrapping repetition ' int2str(rep)])
end

% average all of the repetitions toegether
baseline = squeeze(mean(bootstrapped,4));

filename = sprintf('results_%d%02d%02d_%02d%02d%02.0f',clock);
save(filename)
%%%DEBUG
disp([ sprintf('%d/%d/%d %d:%d:%.0f',clock) ' Done with everything! Saved results to ' filename])

%% plot synchrony
% for 10 neurons, i get 44 figures! oy!

% nFig = 1; % figure to plot in
% 
% for neuron1 = 1:10
%     for neuron2 = (neuron1+1):size(syncs,2)
% 
%         figure(nFig)
%         title([int2str(neuron1) ' with ' int2str(neuron2)])
%         hold all
%         
%         % plot synchrony values
%         plot(squeeze(syncs(neuron1,neuron2,:)))
%         
%         % plot "baseline" synchrony, from bootstrapping
%         plot(squeeze(baseline(neuron1,neuron2,:)))
%         
%         nFig = nFig + 1;
%     end
% end
