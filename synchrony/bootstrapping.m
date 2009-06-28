% Show that we are actually measuring synchrony
%   Generate spike trains and find synchrony. Then, shuffle the bins of
%   spikes and show that synchrony disappears

close all
clear all

%% Define

% user defined stuff
rates = [10 10]; % firing rates, in Hertz
syncpersec = 2; %number of synchronous spikes per second
trainLength = 5; %seconds
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

%% Make spike trains

spikes = makeSpikeTrains3(rates, sync, trainLength, stepSize, offset);

%% Measure synchrony, bin by bin

for mm = 1:nChunks
    rows = (1:chunkSteps) + (mm-1)*chunkSteps;
    synchrony(mm,1) = cps( spikes(rows,:), triangleWidth);
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
    synchrony(mm,2) = cps( newSpikes(rows,:), triangleWidth);
end


%% Analysis

[h p] = ttest2(synchrony(:,1),synchrony(:,2))

myFig = figure
axes('Parent', myFig, 'XTickLabel',{'Original','Shuffled'},'XTick',[1 2])
hold on
means = mean(synchrony);
stds = std(synchrony);
bar(means)
errorbar(means,stds,'.')
xlabel('Bin order')
ylabel('Measured synchrony')
