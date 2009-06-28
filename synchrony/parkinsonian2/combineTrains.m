% make spike trains out of timestamps from files made by findSikes.m

clear all
dt = 0.0002;
% load in all the data
cd('C:\research\data\monkey\parkinsonian2\spikesnippets')
files = dir('C:\research\data\monkey\parkinsonian2\spikesnippets');
files = files(3:end); %get rid of '.' and '..'
nrows = 0;
ncols = length(files);
timestamps = zeros(nrows,ncols);
for n = 1:ncols
    load(files(n).name, 'spikes')
    temp = struct2cell(spikes);
    ts = cell2mat(squeeze(temp(1,1,:))); %time stamps for this channel
    
    % resize timestamps matrix if necessary
    if length(ts) > nrows
        nrows_old = nrows;
        timestamps_old = timestamps;
        nrows = length(ts);
        timestamps = zeros(nrows,ncols);
        timestamps(1:nrows_old,:) = timestamps_old;
    end
    timestamps(1:length(ts),n) = ts;
end
timestamps(timestamps==0) = nan; %timestamps of zero are just an artifact from the way I resize the matrix earlier

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

save('spiketrains', 'spikes', 'dt', 'endTime')