% Show that we are actually measuring synchrony
%   Generate spike trains and find synchrony. Then, shuffle the bins of
%   spikes and show that synchrony disappears
% 
% This particular version uses cps4 which calculates the synchrony measure
% using covariance and takes care of the binning problem. Other than that,
% it should be exactly the same as bootstrapping2


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

rSeed = rand('seed'); %stores the seed for future reference
mFile = mfilename; % name of this m-file
today = date; % today's date

%%%%%%%%%%%%%%%%%%%% END HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define

% user defined stuff
rates = [30 30]; % firing rates, in Hertz
syncpersec = 1:30; %number of synchronous spikes per second
trainLength = 10000; %seconds
stepSize = 0.001; %seconds
offset = 0.005; %seconds
chunk = 10; %seconds

% based on user defined stuff
triangleWidth = 2*1.5*0.005; %2*1.5*offset; %seconds
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
    temp = cps4(spikes, triangleWidth, chunk, chunk, stepSize);
    synchrony(:,1) = squeeze(temp(1,2,:));
    
    
    %% try to find a maximum sync value by doing auto-covariance
    temp = cps4([spikes(:,1) spikes(:,1)], triangleWidth, chunk, chunk, stepSize);
    maxSync = squeeze(temp(1,2,:));
    
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
    temp = cps4(newSpikes, triangleWidth, chunk, chunk, stepSize);
    synchrony(:,2) = squeeze(temp(1,2,:));

    % Some analysis
    meanSyncNormal(ii) = mean(synchrony(:,1));
    stdSyncNormal(ii) = std(synchrony(:,1));
    meanSyncShuffled(ii) = mean(synchrony(:,2));
    stdSyncShuffled(ii) = std(synchrony(:,2));
    meanSyncMax(ii) = mean(maxSync);
    stdSyncMax(ii) = std( maxSync);

    if any(isnan(meanSyncNormal)) || any(isnan(meanSyncShuffled))
        keyboard 
    end
    
end

%% Graph and more analysis

figure
hold all
errorbar(syncpersec, meanSyncNormal, stdSyncNormal, '.b')
errorbar(syncpersec, meanSyncShuffled, stdSyncShuffled, 'xr')
%errorbar(syncpersec, meanSyncMax, stdSyncMax, 'og')
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

% save results
filename = sprintf('results_%d%02d%02d_%02d%02d%02.0f',clock);
save(filename)