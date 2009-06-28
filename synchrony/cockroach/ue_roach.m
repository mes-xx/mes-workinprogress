% ue_roach apply unitary event analysis to cockroach data

debugdisp('Hello World!')

close all
clear all

%%%% Parameters (SET THESE!!) %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = 'C:\research\data\cockroach\cockroach6-19-2008.mat';
dt = 1e-3; % time resolution of spike trains in seconds
n_neurons = 10; %number of neurons

% This is the column that contains trial start times.
col_trial = 11;
% 11 for sim_left or 13 for sim_in

% Length of window for unitary event analysis
T_w = 1; %seconds

% Incement that the unitary event analysis window moves by
dtw = 0.05; %seconds

Delta = 0.005; %bin width (seconds) for unitary event analysis


% cps parameters
triangleWidth = Delta*2 + 1;
binSize = 0.1;
binShift = 0.005;
stepSize = dt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% End of Parameters %%%%%%%%

dw = dtw/dt;
%dw = dtw/Delta; %number of bins to shift window by
b = Delta/dt; % number of time steps in one bin



%% Load data
% load in cockroach data
load(filename)

%% Separate data into trials

t_start = data(:,col_trial); %start times of trials (seconds)
t_start = t_start(~isnan(t_start)); %remove NaN's

T_trial = min(diff(t_start)); %length of one trial (seconds)


% shorten T_trial if necessary to make sure that it is evenly divisible
% into windows
T_trial = floor(T_trial/dtw) * dtw;


t_end = t_start + T_trial; %ending times of trials (seconds)



%% Make spike trains

debugdisp('Data loaded, now making spike trains.')

n_trials = length(t_start);

% trial x time x neuron
spikes = zeros(n_trials, ceil(T_trial/dt), n_neurons);
for neuron = 1:n_neurons
    debugdisp(['Neuron ' int2str(neuron)])
    allSpikeTimes  = data(:,neuron); % get all spike times for this neuron

    for trial = 1:n_trials

        debugdisp(['-->Trial ' int2str(trial)])

        % only get spike times that are in this trial
        spikeTimes = allSpikeTimes( ...
            allSpikeTimes >= t_start(trial) & ...
            allSpikeTimes <  t_end(trial));

        % align spikes so beginning of trial is at t=0
        spikeTimes = spikeTimes - t_start(trial);

        % timesteps where there will be spikes
        t = ceil(spikeTimes/dt);

        % insert spikes!
        spikes(trial, t, neuron) = 1;
    end
end

%% Calculate ue in sliding window

debugdisp('Done making spike trains. Now finding unitary eventns.')

% map each pair of neurons onto a single number
index_lookup = zeros(n_neurons);
ind = 0;
for ii = 1:n_neurons
    for jj = (ii+1):n_neurons
        ind = ind+1;
        index_lookup(ii,jj) = ind;
        index_lookup(jj,ii) = ind;
    end
end



% put into bins
% N_w = T_w/Delta; % number  of time bins in one window
W = round((T_trial - T_w)/dtw); %number of windows in one trial
% temp = reshape(spikes, b, []);
% temp = any(temp,1);
% allBinned = reshape(temp,n_trials, [] ,n_neurons);

% initialize matrix to hold surprise measurements
S = zeros(n_trials,W,ind);


for trial = 1:n_trials
    debugdisp(['Trial ' int2str(trial)])
    for window = 1:W % for each window
        debugdisp(['Window ' int2str(window)])



        timesteps = 1:T_w/dt;
        timesteps = timesteps + (window-1)*dw;
        t(window) = mean(timesteps)*dt;
        local_spikes=spikes(trial,timesteps,:);
        temp = reshape(local_spikes, b,[]);
        temp = any(temp,1);
        binned = reshape(temp,[],n_neurons);
        N_w = size(binned,1);
        % estimate firing rates
        lambda = mean(binned);

        for n1 = 1:n_neurons
            for n2 = (n1+1):n_neurons

                ind = index_lookup(n1,n2);

                % calculate expected coincidences
                npred = N_w*lambda(n1)*lambda(n2);

                % find actual coincidences
                nemp = sum(binned(:,n1) & binned(:,n2));

                % calculate surprise
                Psi = gammainc(nemp,npred,'upper');
                S(trial,window,ind) = log((1-Psi+eps) ./ (Psi+eps) ); %surprise

            end
        end
    end

end

%% Calcuclate cps for comparison
%

W_sync = round((T_trial - binSize)/binShift);
sync = zeros(n_trials, W_sync  ,max(max(index_lookup)));

for trial = 1:n_trials
    timesteps = 1:T_w/dt;
    timesteps = timesteps + (window-1)*dw;
    t(window) = mean(timesteps)*dt;
    local_spikes=spikes(trial,timesteps,:);
    sync_temp = cps_sw( local_spikes, triangleWidth, binSize, binShift, stepSize );
    keyboard;
end
    

%% Plotting

% average over trials
S( S>4 | S<-4 ) = NaN; %get rid of very small or big numbers
y = squeeze(nanmean(S,1));

y2 = squeeze(nanmean(sync,1));

for n1 = 1:n_neurons
    for n2 = (n1+1):n_neurons

        ind = index_lookup(n1,n2);

        figure(1)
        plot(t,y(:,ind))
        title(['Neurons ' int2str(n1) ' and ' int2str(n2) ])
        pause

        %         for trial = 1:n_trials
        %
        %             figure(1)
        %             plot(squeeze(S(trial,:,ind)))
        %             ylim([-4,4])
        %             title(['Neurons ' int2str(n1) ' and ' int2str(n2) '; Trial ' int2str(trial)])
        %             pause
        %         end
    end
end


