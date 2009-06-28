% Show that conv-cov method is independent of firing rate by trying all
% different combinations of firing rates and synchronous spikes and show
% (by pretty figures and ANOVA) that the means only vary in different
% synchrony levels and not at different firing rates. Uses cps4 for faster
% operation (compared to cps3).

close all
clear all

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
rates = 10:10:100;%10:10:200; % firing rates, in Hertz
syncpersec = 0:2:8;%0.5:0.5:10; %number of synchronous spikes per second
trainLength = 10000; %seconds
stepSize = 0.001; %seconds
offset = 0.003;%0.005; %seconds
chunk = 10;%0.090 %seconds

intervalLength = 10; %seconds

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
synchrony = nan(length(sync),length(rates),length(rates),nChunks);

for ii = 1:length(sync)
    for jj = 1:length(rates)
        for kk = jj:length(rates)
            % For every combination of firing rates and synchrony
            disp(['sync ' num2str(syncpersec(ii)) ' rates ' num2str([rates(jj) rates(kk)])])

            spikes = makeSpikeTrains3([rates(jj) rates(kk)], sync(ii), trainLength, stepSize, offset);

            s = cps4( spikes, triangleWidth, chunk, chunk, stepSize );
            synchrony(ii,jj,kk,:) = s(1,2,:);
            synchrony(ii,kk,jj,:) = s(1,2,:);
            keyboard

            



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

% %% ANOVA
% 
% % reshape data into a 2-D matrix where each column is one combination of
% % rates and synchrony and each row is one time chunk
% anovadata = nan(nChunks, nCol);
% col = 0;
% for ii = 1:length(sync)
%     for jj = 1:length(rates)
%         for kk = jj:length(rates)
%             col = col+1;
%             anovadata(:,col) = synchrony(ii,jj,kk,:);
%         end
%     end
% end
% 
% % do the anova
% [p,tbl,stats] = anova1(anovadata);
% [c,m] = multcompare(stats);
% 
% 
% %% Boxplot
% 
% figure
% 
% bpdata = [];
% 
% for col = 1:5
%     bpdata(:,col) = reshape(averaged(col,:,:),[],1);
% end
% 
% boxplot(bpdata)
% ylabel('Synchrony measure')
% xlabel('Number of injected synchronous spikes')


% save results
filename = sprintf('results_%d%02d%02d_%02d%02d%02.0f',clock);
save(filename)