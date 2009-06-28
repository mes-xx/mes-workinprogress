% main - Top level script to run synchrony simulations

clear all


r = 30;%10:10:150; % firing rates
sync = [750 0]; %number of synchronous spikes
trainLength = 200; %seconds
stepSize = 0.001; %seconds
offset = 0.005; %seconds
triangleWidth = 2*1.5*offset; %seconds
% y = nan( length(sync), length(r), length(r) ); %initialize results array

chunk = 0.090; %seconds
chunkSteps = chunk / stepSize;

% figure
% hold all

% for ii = 1:length(sync)
%     % for each synchrony level
% 
%     disp(['Beginning synchrony level ' num2str(sync(ii))])

%     for jj = 1:length(r)
%         for kk = jj:length(r)
%            % for each combination of firing rates
%             rates = [r(jj) r(kk)];
%             disp(['sync ' num2str(sync(ii)) ' rates ' num2str(rates)]);
rates = [30 30];
            spikes = [makeSpikeTrains3( rates, sync(1), trainLength/2, stepSize, offset ); ...
                makeSpikeTrains3(rates, sync(2), trainLength/2, stepSize, offset)];

            nChunks = floor(size(spikes,1)/chunkSteps);
            synchrony = zeros(nChunks,1);
            
            for mm = 1:nChunks
                rows = (1:chunkSteps) + (mm-1)*chunkSteps;
                synchrony(mm) = cps( spikes(rows,:), triangleWidth);
            end
                
%             keyboard
%             
%             y(ii,jj,kk) = sync;
%         end
%     end
% 
%     surf(squeeze(y(ii,:,:)))
% end
middle = floor(size(synchrony,1)/2);
pts = 1;
h = 0;
while ~h
    pts = pts + 1
    if pts > middle
        error('Never different')
    end
    h = ttest2(synchrony(1:pts), synchrony(middle:middle+pts));
end
