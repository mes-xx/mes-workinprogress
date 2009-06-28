% Creates many spike trains using makeSpikeTrains3 and saves them to file

clear all


%% Definitions

firingRates = 10:10:150; %Hertz
% all possible firing rates for simulated neurons

nSyncSpikes = 0:1000:5000; %spikes
% possible numbers of synchronous spikes between neurons

trainLength = 600; %seconds
% length of each spike train

stepSize = 0.001; %seconds
% length of each time step

offset = 0; %seconds
% difference in time between "synchronous" spikes

outdir = '20080609/';
% where to save results

%% Generate spikes

filenum = 1;


% Initialize empty spike trains matrix. Dimensions represent:
%   1 = time step (from 1 to the number of time steps in each train)
%   2 = neuron (either 1 or 2)
%   3 = synchrony level (between 1 and the number of synchrony levels)
%   4 = firing rate of neuron 1 (between 1 and the number of firing rates)
%   5 = firing rate of neuron 2 (between 1 and the number of firing rates)

for ii = 1:length(nSyncSpikes)          % For each combination of synchrony
    sync = nSyncSpikes(ii);             %
    for jj = 1:length(firingRates)      % and firing rates between two
        rate1 = firingRates(jj);        %
        for kk = jj:length(firingRates) % simulated neurons...

                        rate2 = firingRates(kk);
            disp(['sync ' num2str(sync) ' rates ' num2str([rate1 rate2])])

            
            spikes = makeSpikeTrains3( ...
                                    [rate1 rate2], sync, trainLength, ...
                                    stepSize, offset);
            
                                
eval(['spikes' num2str(filenum) '= spikes;']);
filenum = filenum+1;
        end
    end
end