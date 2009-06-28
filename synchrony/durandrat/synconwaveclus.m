clear all

files = {'C:\Data\durandrat\times_U081217-5Sel2_ch3_waveclus.mat', [1]; ...
    'C:\Data\durandrat\times_U081217-5Sel2_ch4_waveclus.mat', [1,2]}
N_neurons = 0;
spikes = [];
neurons = cell(0,2);
bootstrapReps = 200;

% load saved data from wave_clus
for n_file = 1:length(files)
    load(files{n_file,1}, 'cluster_class');
    for cluster = files{n_file,2}
        % for each cluster that we want from this file...
        
        % select the spike times for this cluster. cluster number is in the
        % first column of cluster_class and the spike time is in the second
        % column
        spiketimes = cluster_class(cluster_class(:,1)==cluster,2);

        % next we will put these spikes in our spikes matrix, but first we
        % need to determine which number neuron this will be.
        N_neurons = N_neurons+1; % just make this the next neuron
        neurons{N_neurons,1} = files{n_file,1};
        neurons{N_neurons,2} = cluster; 
        % make a record of this in our neurons table. first column is the 
        % file name, second column is the cluster number
        
        % the spike times are in units of milliseconds. round off the
        % numbers then we can use them as row numbers for spikes matrix.
        % each row is one millisecond
        rows = round(spiketimes);
        spikes(rows,N_neurons) = 1; % insert ones where there are spikes
    end
    
    clear cluster_class 
    % clear this variable so we can load one of the same name from the next
    % file.
end

%%% parameters for conv-cov analysis %%%%%%%%%%%%%%
data.dt = 1e-3; %seconds
data.tWindow = 1; %seconds
data.tSlide = 0.01; %seconds
data.tTriangle = 2*1.5*0.005; %seconds
%              = 2*1.5*jitter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.spikes = spikes;

%% Find actual synchrony
% calculate synchrony in original data without shuffling bins

debugdisp('Calculating true synchrony')
sync = convcov(data);

%% Do bootstrapping

% initialize variable to store synchrony from bootstrapping
sync_bs = zeros([size(sync) bootstrapReps]);

for rep = 1:bootstrapReps
    debugdisp(['Starting bootstrap iteration ' int2str(rep)])
    
    % shuffle spike trains
    shuffleChunkSteps = 50;
    data.spikes = shuffleBins(data.spikes, shuffleChunkSteps);
    
    % find synchrony
    sync_bs(:,:,:,rep) = convcov(data);
end

%% Plot results

% make time vectors for the data
t_sync = (0:size(sync,3)-1) * data.tSlide + data.tWindow/2;
t_spike = (0:size(spikes,1)-1) * data.dt;

% for each pair of neurons
for n1 = 1:N_neurons
    for n2 = (n1+1):N_neurons
        
        figure
        title([int2str(n1) ' vs ' int2str(n2)])
        hold all
        
        % plot true sync in blue
        y = squeeze(sync(n1,n2,:));
        plot(t_sync,y,'-b')
        
        % plot average bootstrap in red
        temp = mean(sync_bs,4);
        y = squeeze(temp(n1,n2,:));
        plot(t_sync,y,'-r')
        
        % plot 95th percentiles of bootstrap in dotted red
%%%FIXME
        
        % plot spikes as black 

            y = 0.06*spikes(:,n1) + 0.1;
            plot(t_spike,y,'-k')
            
            y = 0.06*spikes(:,n2) + 0.2;
            plot(t_spike,y,'-k')
        
            
            
        pause
    end
end