% Performs convcov on neuroXidence toy data

%% HEADER
% This bit of code is (or should be) at the top of all of my m-files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isunix
    % If we are on a unix machine, then we are on the cluster. We need to
    % add my toolbox directory to the path.
    addpath(genpath('/home/mes41/toolbox/'))
end
    
debugdisp('Hello world!')

clear all
close all

rSeed = rand('twister'); %stores the seed for future reference
mFile = mfilename; % name of this m-file
today = date; % today's date

%%%%%%%%%%%%%%%%%%%% END HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load data

% -------------------------------------------------------------------------
% Load Example dataset + ++++++++++++++++++++++++++++++++++++++++++++++++++
% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
% ## The example dataset contains 3 neurons in 50 trials with 6 different periods:
% ## 1: 0-2s and 7-8s independent spike trains at 30ap/s
% ## 2: 2-3s spike rate at 30ap/s and first and second spike trains share synchronized spikes (SIP -process correlation spike rate 5JSE/s)
% ## 3: 3-4s spike rate at 15ap/s and first and second spike trains share synchronized spikes (SIP -process correlation spike rate 2JSE/s)
% ## 4: 4-5s spike rate at 30ap/s and first and second spike trains share synchronized spikes (SIP -process correlation spike rate 5JSE/s)
% ## 5: 5-6s spike rate at 30ap/s and first, second and third spike trains share synchronized spikes (SIP -process correlation spike rate 2JSE/s)
% ## 6: 6-7s spike rate at 30ap/s and first, second and third and second spike trains share synchronized spikes (SIP -process correlation spike rate 5JSE/s)
% ## -------------------------------------------------------------------------


load('c:\research\code\matlab\toolbox\NeuroXidence_Matlab_Full_Source_Code_package_V3_3_4\Toy_Data_set_2.mat')

%% set parameters

%%% parameters for conv-cov analysis %%%%%%%%%%%%%%
data.dt = 1e-3; %seconds
data.tWindow = 1; %seconds
data.tSlide = 0.01; %seconds
data.tTriangle = 2*1.5*0.005; %seconds
%              = 2*1.5*jitter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract some other parameters from the neuroXidence. I do this now
% because I want to be able to pre-allocate the spikes matrix before I
% start the main loop.
% ASSUME that the first neuron is 1 and time starts at 0
nTrials = length(GDF_all_trials);
nNeurons = 1; % how many neurons?
t_max = 0; % when does time end?
for trial = 1:nTrials
    nNeurons = max([nNeurons, GDF_all_trials{trial}(2,:)]);
    t_max = max([t_max, GDF_all_trials{trial}(1,:)]);
end

t = 0:data.dt:t_max; % vector of time steps (matches up with spikes matrix)

nBins = floor( (t(end) - data.tWindow) / data.tSlide);
t_sync = (0:nBins) * data.tSlide + data.tWindow/2;
% t_sync = (data.tWindow/2):data.tSlide:(t_max-data.tWindow/2);
% ^^ vector of time steps, for synchrony data. time values are at the
% center of each analysis window.

% initialize vatiable to store calculated synchrony
syncs = nan(nNeurons,nNeurons,length(t_sync),nTrials);

%% main loop
for trial = 1:nTrials
    debugdisp(sprintf('Trial %d of %d',trial,nTrials))
    data.spikes = zeros(length(t),nNeurons); % initialize spike matrix
    
    % assign this trial's data to a temprorary variable for easier
    % processing. cell arrays are a bitch.
    tmp.t = GDF_all_trials{trial}(1,:); % these are spike times 
    tmp.n = GDF_all_trials{trial}(2,:); % these are neurons to match spike times above
    
    for neuron = 1:nNeurons % for each neuron
        ind = ceil(tmp.t( neuron == tmp.n ) ./ data.dt);
        % ^^ find indices where spikes should be inserted.
        % select all times that match spikes for spikes number "neuron" as
        % stored in tmp.n. divide by dt to convert from time into timestep
        
        data.spikes(ind,neuron) = 1; % insert the damn spikes!
    end
    
    % find the synchrony for this trial
    syncs(:,:,:,trial) = convcov(data);
end

%% plot results

% average over all trials
avg = squeeze(mean(syncs,4)); % average
dev = squeeze(std(syncs,1,4)); % standard deviation

% for each pair of neurons, plot the results
for n1 = 1:nNeurons
    for n2 = (n1+1):nNeurons
        figure
        hold all
        title(sprintf( '%d versus %d', n1,n2))
        y = squeeze(avg(n1,n2,:));
        plot(t_sync, y, '-b', 'LineWidth',3)
        y = squeeze(avg(n1,n2,:)+dev(n1,n2,:));
        plot(t_sync, y, ':g')
        y = squeeze(avg(n1,n2,:)-dev(n1,n2,:));
        plot(t_sync, y, ':g')
        xlabel('Time')
        ylabel('Synchrony')
    end
end


%% save
filename = sprintf('results_%d%02d%02d_%02d%02d%02.0f',clock);
save(filename)