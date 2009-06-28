% Plot unitary events vs our synchrony measure
% To make a plot that compares synchrony measure vs number of synchronous
% spikes, see bootstrapping3.m

close all
clear all

%% Define

% user defined stuff
rates = [30 30]; % firing rates, in Hertz
syncpersec = 1:30; %number of synchronous spikes per second
trainLength = 600; %seconds
stepSize = 0.001; %seconds
offset = 0.005; %seconds
chunk = 0.090; %seconds

% parameters for unitary event method
h       = stepSize;
Delta   = offset;
Tau     = chunk;
S_alpha = 2; %between 1.28 and 2, according to the papers

% based on user defined stuff
triangleWidth = 2*1.5*offset; %seconds
chunkSteps = chunk / stepSize; %number of time steps per chunk
sync = syncpersec * trainLength; %number of synchronous spikes in the whole train
nChunks = floor(trainLength/chunk);

% initialize for later use
synchrony = zeros(nChunks,2);
meanSyncNormal = zeros(size(sync));
stdSyncNormal = zeros(size(sync));
meanSyncShuffled = zeros(size(sync));
stdSyncShuffled = zeros(size(sync));

ue = zeros(nChunks,2);
meanUeNormal = zeros(size(sync));
stdUeNormal = zeros(size(sync));
meanUeShuffled = zeros(size(sync));
stdUeShuffled = zeros(size(sync));

%% Loop
for ii = 1:length(sync)
    
    disp(['sync ' num2str(syncpersec(ii))])

    % Make spike trains
    spikes = makeSpikeTrains3(rates, sync(ii), trainLength, stepSize, offset);

    % Measure synchrony, bin by bin
    temp = cps4(spikes, triangleWidth, chunk, stepSize);
    synchrony(:,1) = squeeze(temp(1,2,:));
    temp = unitaryEvents(spikes, h, Delta, Tau, S_alpha);
    ue(:,1) = temp(1:end-1); %off by one error?
    
    %% Shuffle order of bins

    newSpikes = zeros(size(spikes));
    newOrder = randperm(nChunks);

    for newChunk = 1:nChunks
        newRows = (1:chunkSteps) + (newChunk-1)*chunkSteps;
        oldChunk = newOrder(newChunk);
        oldRows = (1:chunkSteps) + (oldChunk-1)*chunkSteps;

        newSpikes(newRows,2) = spikes(oldRows,2);
    end

    newSpikes(:,1) = spikes(:,1);

    %% Measure synchrony again
    temp = cps4(newSpikes, triangleWidth, chunk, stepSize);
    synchrony(:,2) = squeeze(temp(1,2,:));
    temp = unitaryEvents(newSpikes, h, Delta, Tau, S_alpha);
    ue(:,2) = temp(1:end-1); % off by one error?

    % Some analysis
    meanSyncNormal(ii) = mean(synchrony(:,1));
    stdSyncNormal(ii) = std(synchrony(:,1));
    meanSyncShuffled(ii) = mean(synchrony(:,2));
    stdSyncShuffled(ii) = std(synchrony(:,2));
    meanUeNormal(ii) = mean(ue(:,1));
    stdUeNormal(ii) = std(ue(:,1));
    meanUeShuffled(ii) = mean(ue(:,2));
    stdUeShuffled(ii) = std(ue(:,2));

    if any(isnan(meanSyncNormal)) || any(isnan(meanSyncShuffled))
        keyboard 
    end
    
end

%% Graph and more analysis

figure
hold all
scatter(meanUeNormal, meanSyncNormal,'.b')
scatter(meanUeShuffled, meanSyncShuffled,'xr')

X = [syncpersec; ones(size(syncpersec))]';
[b1,bint1,r1,rint1,stats1] = regress(meanSyncNormal',X);
[b2,bint2,r2,rint2,stats2] = regress(meanSyncShuffled',X);
[b3,bint3,r3,rint3,stats3] = regress(meanUeNormal',X);
[b4,bint4,r4,rint4,stats4] = regress(meanUeShuffled',X);

Y = [meanUeNormal; ones(size(meanUeNormal))]';
[b5,bint5,r5,rint5,stats5] = regress(meanSyncNormal',Y);

plot(meanUeNormal,Y*b5,'-b')


xlabel('Unitary events')
ylabel('Measured synchrony')
