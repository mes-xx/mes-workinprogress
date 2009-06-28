% Bootstrapping for Crazy's data
clear all;close  all
load('C:\Documents and Settings\Michael\My Documents\MATLAB\synchrony\results20080612c.mat','data');

nChunks = 6666;
chunkSteps = 90;

nRep = 50;
newsynchrony = zeros(nChunks,nRep,5);
binSize = 0.09;
stepSize = 0.001;
offset = 0.005;
triangleWidth = (2*1.5*(offset+stepSize/2));

sets = { [data(:,4) data(:,19)], ...
    [data(:,1) data(:,17)], ...
    [data(:,3) data(:,13)], ...
    [data(:,21) data(:,22)], ...
    [data(:,10) data(:,16)]};

clear data

for set = 1:5

    spikes = sets{set};

    for rep = 1:nRep
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
        temp = cps4( spikes, triangleWidth, binSize, stepSize );
        newsynchrony(:,rep,set) = squeeze(temp(1,2,:));

    end
end
%%


meaned = newsynchrony(:,1,:);%squeeze(mean(newsynchrony,2));
% filter syncrony
windowSize = 33; % about a 3 second sliding window
filtered = filter(ones(1,windowSize)/windowSize,1,meaned,[],1);

% show synchrony varies over range shown by simulation.  these scale
% values were found from results20080612a
sp0 = -3.8273e-005;
sp4 = 0.0067;
sp8 = 0.0134;

L = length(filtered);
t = 0:binSize:(binSize*(L-1));

for set = 1:5



    % this is the same for all graphs
    figure
    plot(t,ones(L,1)*sp0,'--b','LineWidth',2);
    hold all
    plot(t,ones(L,1)*sp4,'--g','LineWidth',2);
    plot(t,ones(L,1)*sp8,'--r','LineWidth',2);
    legend('0 coincidences per second','4 coincidences per second','8 coincidences per second','filtered data')
    xlabel('Time, seconds')
    ylabel('Measured synchrony')
    title(['set = ' num2str(set)])

    % data for this pair
    plot(t,squeeze(filtered(:,set)),'-k')

    %        pause
    hold off
end
%end