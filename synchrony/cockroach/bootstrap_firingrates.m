addpath(genpath('/home/mes41/toolbox'))

debugdisp('Hello world!')

clear all
close all

rSeed = rand('seed');

% use this file to build spike trains from scratch  (should also uncomment
% Make spike trains section below)
%filename = 'C:\research\data\cockroach\cockroach6-19-2008.mat';

% this file already has spike trains built, to save a lot of time (make
% sure Make Spike Trains section is commented out)
%filename = 'cockroach_spikes_100msTrials.mat';

%%%%%%%%% New for simulations test%%%%%%%%%%%%%%%%
filename= 'testspikes20090204.mat';
n_trials = 10000;
n_neurons = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%n_neurons = 10;

n_points = 100000;
binSize = 0.1; %seconds
dt = 0.001; %seconds
xList = 0:21;
yList = 0:21;

triangleWidth = 0.011;





T_trial = binSize;

% Load data
debugdisp('Loading data')
load(filename,'spikes','n_trials')

%% Make spike trains

% debugdisp('Making spike trains')
% t_start = 0:binSize:(max(max(data))+binSize);
% t_end   = t_start + binSize - dt;
% 
% n_trials = length(t_start);
% 
% % trial x time x neuron
% spikes = zeros(n_trials, ceil(T_trial/dt), n_neurons);
% for neuron = 1:n_neurons
%     debugdisp(['Neuron ' int2str(neuron)])
%     allSpikeTimes  = data(:,neuron); % get all spike times for this neuron
% 
%     for trial = 1:n_trials
% 
%         %         debugdisp(['-->Trial ' int2str(trial)])
% 
%         % only get spike times that are in this trial
%         spikeTimes = allSpikeTimes( ...
%             allSpikeTimes >= t_start(trial) & ...
%             allSpikeTimes <  t_end(trial));
% 
%         % align spikes so beginning of trial is at t=0
%         spikeTimes = spikeTimes - t_start(trial);
% 
%         % timesteps where there will be spikes
%         t = ceil(spikeTimes/dt);
%         
%         % make sure there is no spike @ t = 0
%         t(t==0) = 1;
% 
%         % insert spikes!
%         spikes(trial, t, neuron) = 1;
%     end
% end

%% Estimate firing rate in each bin

debugdisp('Estimating firing rates')
firingRates = squeeze(sum(spikes,2));

%% Throw out bins with no spikes

debugdisp('Discarding bins with no spikes')

for neuron = 1:n_neurons
   badTrials{neuron} = find(firingRates(:,neuron) == 0);
   
   goodTrials{neuron} = setdiff(1:n_trials, badTrials{neuron});
end
    
%% Loop through neurons and make the plots
for n1 = 1:n_neurons            %
    for n2 = (n1+1):n_neurons   % for each pair of neurons
        debugdisp(['Beginning analysis of neuron pair: ' int2str(n1) ' vs ' int2str(n2)])
        z = zeros( length(xList), length(yList) );
        n = z;
        for b1 = 1:n_trials
            debugdisp(['bin ' int2str(b1) ' of ' int2str(n_trials)])
            if ~any(goodTrials{n1} == b1)
                continue
            end
            
            for b2 = 1:n_trials
                if ~any(goodTrials{n2} == b2)
                    continue
                end
%         for p = 1:n_points  % repeat for n_points points            
% 
%             % Randomly select a pair of GOOD bins
%             temp = goodTrials{n1};
%             b1 = temp( ceil(rand*length(temp)) );
%             temp = goodTrials{n2};
%             b2 = temp( ceil(rand*length(temp)) );


            % Find synchrony between the bins
            temp = cps4([spikes(b1,:,n1)' spikes(b2,:,n2)'], triangleWidth, binSize, binSize, dt);
            sync = temp(1,2);
            
            
            
            % Determine where to put this point based on firing rates
            xi = find( firingRates(b1,n1) >= xList , 1, 'last' );
            yi = find( firingRates(b2,n2) >= yList , 1, 'last' );
            
            % Update the average at the chosen point with new sync value
            z(xi,yi) = (z(xi,yi)*n(xi,yi) + sync)  /  (n(xi,yi) + 1);
            n(xi,yi) = n(xi,yi) + 1;

            end
        end
        
        % Don't plot points that don't include any neurons
        z(n == 0) = NaN;
        
        % Now that we have all the points for this pair of neurons, make
        % the plot!
        imagesc(xList,yList,z)
        title([int2str(n1) ' vs ' int2str(n2)])
        
        debugdisp(['Done with analysis of neuron pair: ' int2str(n1) ' vs ' int2str(n2)])
        
        save( ['results_btstrp_fr_' int2str(n1) '_' int2str(n2)] )
        
%         pause
    end
end