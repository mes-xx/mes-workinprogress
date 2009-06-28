% Show that we are actually measuring synchrony
%   Generate spike trains and find synchrony. Then, shuffle the bins of
%   spikes and show that synchrony disappears
% 
% This particular version uses  cps2 which calculates the synchrony measure
% using correlation instead of covariance

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

%% Loop
for ii = 1:length(sync)
    
    disp(['sync ' num2str(syncpersec(ii))])

    % Make spike trains
    spikes = makeSpikeTrains3(rates, sync(ii), trainLength, stepSize, offset);

    % Measure synchrony, bin by bin
    for mm = 1:nChunks
        rows = (1:chunkSteps) + (mm-1)*chunkSteps;
        synchrony(mm,1) = cps2( spikes(rows,:), triangleWidth);
    end

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

    for mm = 1:nChunks
        rows = (1:chunkSteps) + (mm-1)*chunkSteps;
        synchrony(mm,2) = cps2( newSpikes(rows,:), triangleWidth);
    end

    % Some analysis
    meanSyncNormal(ii) = mean(synchrony(:,1));
    stdSyncNormal(ii) = std(synchrony(:,1));
    meanSyncShuffled(ii) = mean(synchrony(:,2));
    stdSyncShuffled(ii) = std(synchrony(:,2));

    if any(isnan(meanSyncNormal)) || any(isnan(meanSyncShuffled))
        keyboard 
    end
    
end

%% Graph and more analysis

figure
hold all
errorbar(syncpersec, meanSyncNormal, stdSyncNormal, '.b')
errorbar(syncpersec, meanSyncShuffled, stdSyncShuffled, 'xr')
% scatter(syncpersec, meanSyncNormal,'.b')
% scatter(syncpersec, meanSyncShuffled,'xr')

X = [syncpersec; ones(size(syncpersec))]';

[b1,bint1,r1,rint1,stats1] = regress(meanSyncNormal',X);
plot(syncpersec,X*b1,'-b')

[b2,bint2,r2,rint2,stats2] = regress(meanSyncShuffled',X);
plot(syncpersec,X*b2,'-r')

disp(bint2)

xlabel('Synchronous spikes per second')
ylabel('Measured synchrony')
legend('Original bin order', 'Shuffled bins')

