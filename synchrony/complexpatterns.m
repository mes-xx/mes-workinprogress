%COMPLEXPATTERNS Evaluate cps performance on patterns between 4 neurons
%   Based on Gordon Pipa's PhD dissertation (available from NeuroXidence's
%   Google Group), Figure 7.1 shows that there are a fair number of events
%   detected with complexities of 3 or 4. Until now, all the analysis I
%   have done with cps has been on pairs of neurons. So, now I will try
%   using four neurons and try to distinguish events involving 2, 3, or 4
%   neurons. I think it can be done by seeing of all the covariances are
%   high. For example, if the covariances between [1 and 2], [1 and 3], and
%   [2 and 3] are all high, then it is a joint spike event involving all
%   three neurons. On the other hand, if only the covariances between [3
%   and 4] are high, then the event only involves those two neurons.

%% Parameters
% Adjust these.

% time step for simulation
dt = 0.001; %seconds

% total neurons to simulate
total_neurons = 4;

% the spike trains will be broken up into chunks of  this size for analysis
analysis_window = 0.1; %seconds

% width of triangle used in cps method
triangleWidth = 0.011; %11ms

% the simulated data will be divided into epochs. Each epoch has:
%   length (in seconds): how long this epoch lasts. Epochs will be arranged
%     end-to-end in ascending order.
%   jseNeurons: a list of neurons that are involved in joint spike events
%     (JSEs). If jseNeurons is empty or a scalar, then there will be no 
%     JSEs. If jseNeurons is a list of two neurons, then those two neurons
%     will fire synchronously (similar to everything I have already been
%     testing). If jseNeurons is a list of more than two neurons, then all
%     of those neurons will spike at (approximately) the same time.
%   jitter (in seconds): the precision of JSEs. All of the spikes of a JSE
%     will occur within the jitter window.
%   firingRates (in Hz): a list that specifies the firing rates for each
%     of the neurons (must be totalNeurons in length).
%   jseRate (in Hz): the rate at which JSEs occur. Cannot be higher than
%     the firingRate of the slowest-firing neuron involved.

epochs(1).length = 500; %seconds
epochs(1).jseNeurons = [1 2]; 
epochs(1).jitter = 0.006; %6 ms
epochs(1).firingRates = [30 30 30 30]; %Hz
epochs(1).jseRate = 10; %Hz

% the second epoch is the same as the first, but JSEs include 3 neurons
epochs(2) = epochs(1);
epochs(2).jseNeurons = [1 2 4];

% the third epoch has no JSEs
epochs(3) = epochs(2);
epochs(3).jseRate = 0;

%%%%%% DO NOT CHANGE ANYTHING BELOW THIS LINE %%%%%%

%% Generate spike trains

spikes = [];

% for each epoch
for n = 1:length(epochs)
    
    length_steps = epochs(n).length / dt;
    jitter_steps = epochs(n).jitter / dt;
    total_spikes = epochs(n).firingRates * epochs(n).length;
    total_jses   = epochs(n).jseRate     * epochs(n).length;
    jse_neurons  = epochs(n).jseNeurons;
    
    spikes_temp = zeros( length_steps, total_neurons );

    %% add in JSEs
    
    % make sure JSEs don't overlap by only selecting indices that are at
    % least jitter_steps apart
    ind = randperm( floor( length_steps / jitter_steps ) );
    ind = ind .* jitter_steps;
    
    % select the proper number of JSE indices
    ind = ind(1:total_jses);
    
    % jitter the JSE indices so that the exact spike time is a little
    % different in each neuron involved
    ind = ind' * ones(1,length(jse_neurons));
    ind = ind + round( jitter_steps * rand(size(ind)) );
    
    for col = 1:length(jse_neurons)
        % for each of the neurons involved in JSEs,
        
        % put in the spikes for the JSEs
        spikes_temp(ind(:,col), jse_neurons(col)) = 1;        
    end
        
    % now go through and put in randomly spaced spikes (like independent
    % poisson process) so that each neuron has the proper number of spikes.
    
    % before we start that, though, see how many spikes each neuron still
    % needs. This number will be lower if the neuron was involved in JSEs
    % earlier.
    spikes_needed = total_spikes - sum(spikes_temp);
    
    % okay, now go through each neuron and give it spikes
    for neuron = 1:total_neurons
        
        % find places where there are no spikes. we only want to put our
        % new spikes where there isn't a spike already.
        nospikes = find( ~spikes_temp(:,neuron) );
        
        % now take a random bunch of places where there are no spikes and
        % put spikes there
        ind = randperm(length(nospikes));
        ind = ind(1:spikes_needed(neuron));
        rows = nospikes(ind);
        spikes_temp(rows, neuron) = 1;
    end
    
    % add the epoch to whatever we have already
    spikes = [spikes; spikes_temp];
end

%% Measure Synchrony
% Use the handy dandy conv-cov or "cps" method to get a measure of the
% synchrony between pairs of neurons.

syncs = cps4( spikes, triangleWidth, analysis_window, dt );