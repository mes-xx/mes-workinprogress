% Show that conv-cov method is independent of firing rate by trying all
% different combinations of firing rates and synchronous spikes and show
% (by pretty figures and ANOVA) that the means only vary in different
% synchrony levels and not at different firing rates

close all
clear all

%% Define

% user defined stuff
rates = 10:10:100;%10:10:200; % firing rates, in Hertz
syncpersec = 0:2:8;%0.5:0.5:10; %number of synchronous spikes per second
trainLength = 1000; %seconds
stepSize = 0.001; %seconds
offset = 0.003;%0.005; %seconds
chunk = 0.090; %seconds

% based on user defined stuff
triangleWidth = (2*1.5*(offset+stepSize/2)); %seconds
chunkSteps = chunk / stepSize; %number of time steps per chunk
sync = syncpersec * trainLength; %number of synchronous spikes in the whole train
nChunks = floor(trainLength/chunk);

% initialize for later use
synchrony = nan(length(sync),length(rates),length(rates),nChunks);
leftovers = [0 0];
nCol = 0;

%% Loop

for ii = 1:length(sync)
    for jj = 1:length(rates)
        for kk = jj:length(rates)
            % For every combination of firing rates and synchrony
            disp(['sync ' num2str(syncpersec(ii)) ' rates ' num2str([rates(jj) rates(kk)])])

            spikes = makeSpikeTrains3([rates(jj) rates(kk)], sync(ii), trainLength, stepSize, offset);

            for mm = 1:nChunks
                rows = (1:chunkSteps) + (mm-1)*chunkSteps;
                [s leftovers] = cps3(spikes(rows,:), triangleWidth, leftovers);
                synchrony(ii,jj,kk,mm) = s;
                synchrony(ii,kk,jj,mm) = s;
            end
            
            nCol = nCol + 1;

        end
    end
end

%% Pretty figure

averaged = mean(synchrony,4);

figure
hold all
for ii = 1:2:size(synchrony,1)
    surf(rates,rates,squeeze(averaged(ii,:,:)))
end
ylabel('Firing rate 1')
xlabel('Firing rate 2')
zlabel('Measured synchrony')
%% ANOVA

% reshape data into a 2-D matrix where each column is one combination of
% rates and synchrony and each row is one time chunk
anovadata = nan(nChunks, nCol);
col = 0;
for ii = 1:length(sync)
    for jj = 1:length(rates)
        for kk = jj:length(rates)
            col = col+1;
            anovadata(:,col) = synchrony(ii,jj,kk,:);
        end
    end
end

% do the anova
[p,tbl,stats] = anova1(anovadata);
[c,m] = multcompare(stats);


%% Boxplot

figure

bpdata = [];

for col = 1:5
    bpdata(:,col) = reshape(averaged(col,:,:),[],1);
end

boxplot(bpdata)
ylabel('Synchrony measure')
xlabel('Number of injected synchronous spikes')
