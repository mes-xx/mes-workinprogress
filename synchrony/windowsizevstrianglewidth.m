% Shows the effect of analysis window size on (a) the average value of the
% measurement and (b) the variability of the measurement

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

stepSize = 0.001; %seconds
trainLength = 1000; %seconds
triangleWidth = 0.02; %seconds, optimized for 3 ms offset
rates = [100 100]; %Hertz
nSync = 10*trainLength; %spikes
offset = 0; %seconds
windowSizes = exp(linspace( log(0.03), log(30) ));


spikes = makeSpikeTrains3(rates, nSync, trainLength, stepSize, offset );


%[0.02:0.01:0.2 0.25:0.05:0.5];
variability = zeros(size(windowSizes));
average = zeros(size(windowSizes));

for nSize = 1:numel(windowSizes)
    debugdisp(['Iteration ' int2str(nSize)])
    binSize = windowSizes(nSize);
    temp = cps4( spikes, triangleWidth, binSize, binSize, stepSize );
    syncs{nSize} = squeeze(temp(1,2,:));
%     [h p] = chi2gof(syncs{nSize});
%     handp(:,nSize) = [h p];
    variability(nSize) = std(syncs{nSize});
    average(nSize) = mean(syncs{nSize});
end


figure(5)

subplot(1,2,1)
plot(windowSizes,variability)
xlabel('Window size (seconds)')
ylabel('Standard deviation')
title('(a)')
xlim([ min(windowSizes) max(windowSizes) ])

subplot(1,2,2)
plot(windowSizes,average)
xlabel('Window size (seconds)')
ylabel('Mean')
title('(b)')
xlim([ min(windowSizes) max(windowSizes) ])