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

rand('twister',sum(100*clock)) % set a new state value each time
rSeed = rand('twister'); %stores the state for future reference
mFile = mfilename; % name of this m-file
today = date; % today's date

% DEBUG_TEXT determines whether debugdisp() function will display any
% output. Set to 0 to suppress output. 
global DEBUG_TEXT
DEBUG_TEXT = 1; 

%%%%%%%%%%%%%%%%%%%% END HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define these paramters


bootstrapReps = 1; % number of times to repeat bootstrapping

% when shuffling, chunks of data are moved around together. each chunk will
% be this many time steps long:
shuffleChunkSteps = 100; % = 100 ms

%%% parameters for conv-cov analysis %%%%%%%%%%%%%%
data.dt = 1e-3; %seconds
data.tWindow = 1; %seconds
data.tSlide = 0.01; %seconds
data.tTriangle = 2*1.5*0.005; %seconds
%              = 2*1.5*jitter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% load data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
debugdisp('Loading data')
load('c:\data\durandrat\U081217-5Sel2_clean_strobe.mat')
% trim spike train so that the first spike is in the first time step. I
% already know that the last spike is in the last time step because of how
% the spike train was created.
begin = find(any(strobe,2),1,'first');
strobe = strobe(begin:end,:);

% resample data to 1ms bins
data.spikes = binSpikes(strobe,1/24414,1e-3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Find actual synchrony
% calculate synchrony in original data without shuffling bins

debugdisp('Calculating true synchrony')
sync = convcov(data);

%% Do bootstrapping

% initialize variable to store synchrony from bootstrapping
sync_bs = zeros([size(sync) bootstrapReps]);

for rep = 1:bootstrapReps
    debugdisp(['Starting bootstrap iteration ' int2str(rep)])
    
    % shuffle spike trains
    data.spikes = shuffleBins(data.spikes, shuffleChunkSteps);
    
    % find synchrony
    sync_bs(:,:,:,rep) = convcov(data);
end



%% Graph and more analysis

% figure
% hold all
% errorbar(syncpersec, meanSyncNormal, stdSyncNormal, '.b')
% errorbar(syncpersec, meanSyncShuffled, stdSyncShuffled, 'xr')
% %errorbar(syncpersec, meanSyncMax, stdSyncMax, 'og')
% % scatter(syncpersec, meanSyncNormal,'.b')
% % scatter(syncpersec, meanSyncShuffled,'xr')
% 
% X = [syncpersec; ones(size(syncpersec))]';
% 
% [b1,bint1,r1,rint1,stats1] = regress(meanSyncNormal',X);
% plot(syncpersec,X*b1,'-b')
% 
% [b2,bint2,r2,rint2,stats2] = regress(meanSyncShuffled',X);
% plot(syncpersec,X*b2,'-r')
% 
% disp(bint2)
% 
% xlabel('Synchronous spikes per second')
% ylabel('Measured synchrony')
% legend('Original bin order', 'Shuffled bins')

% save results
filename = sprintf('results_%d%02d%02d_%02d%02d%02.0f',clock);
save(filename)

debugdisp('Goodbye world!')