% Finds spikes in unit recordings and stores them in a way that is easy to
% load into MClust

% This was originally made to process extracellular recordings from a
% monkey. Dawn gave me the data from the Clinic.

clear all
close all
%% Parameters that you should set

filename = 'C:\research\data\monkey\parkinsonian2\A2208031_spikedata.mat';
load(filename) % should contain a variable called spikedata

%spikedata = some_other_variable_loaded_from_file;
%dt = 1/25000; %seconds, sampling period
dt = 1/samprate; %determine sampling period from loaded variable samprate
t = 0:dt:(dt*size(spikedata,1));
threshold.std = -1.5; % number of standard deviations 
threshold.value = threshold.std * std(spikedata);
%threshold.value = 50e-6*ones(1,size(spikedata,2)); %volts
%window.time = 0.0013; %seconds
%window.samples = ceil(window.time/dt);
window.samples = 32; %samples

% By this point, spikedata, threshold.value, window.samples, t MUST be
% defined. 

%% Find spikes

% add this to the starting index of the spike to get all the indices in the
%  spike window.
window.mask = (1:window.samples) - floor(window.samples/4);

[nrows ncols] = size(spikedata);
[pathstr, name, ext, versn] = fileparts(filename);

debugdisp('Loaded data and set parameters.')

% Show the spikes and thresholds to make sure everything looks good
% figure
% for col = 1:ncols
%     plot(spikedata(:,col))
%     hold all
%     plot(threshold.value(col)*ones(nrows,1))
% 
%     hold off
%     title(['channel ' int2str(col)])
%     pause
% end

% Find threshold all places where the signal is outside the threshold. If
% the threshold is positive, then the signal must be higher than threshold.
% If the threshold is negative then the signal must be lower than the
% threshold.
if threshold.value < 0
    ind_outside = spikedata < ones(size(spikedata,1),1)*threshold.value;
else
    ind_outside = spikedata > ones(size(spikedata,1),1)*threshold.value;
end
debugdisp('Found parts that are outside of threshold.')

% Find all the places where the threshold is crossed from inside to outside
ind_crosses = ~ind_outside(1:end-1,:) & ind_outside(2:end,:);
debugdisp('Found threshold crossings')

for col = 1:ncols %for each channel
    debugdisp(['Processing spikes for channel ' int2str(col)])
    ind_spikes = find(ind_crosses(:,col)); % this is where the spikes are
    
    % make sure no spikes are too close to the edges. if a spike is too
    % close to an edge, then the window will extend past the recording!
    ind_spikes = ind_spikes( ...
        (ind_spikes+min(window.mask)) > 0  & ...
        (ind_spikes+max(window.mask)) < nrows);

    
    spikes = struct('time',num2cell(t(ind_spikes)),'waveform',[]);

    for n = 1:length(spikes) %for each spike
        spikes(n).waveform = spikedata(window.mask + ind_spikes(n),col);
    end
    
    % save spikes (and other useful information) to file. each channel gets
    % its own file.
    output_filename = [pathstr '\' name '_sp' int2str(col)];
    save(output_filename, 'threshold','window','dt','filename','spikes')

end

debugdisp('Done.')

% figure
% hold all
% for n = 1:100
%     plot(spikes(n).waveform)
% end