% bootstrap_plots_behavioral3b plots results from bootstrap_plots_behavioral3
%
% bootstrap_plots_behavioral3 can be run separately (on the high
% performance computing cluster, for example) and then this script should
% be run on a computer you are sitting at to see the results.

clear all
close all

filename = 'results_20090226_160416.mat'

% confidence level for dotted lines to indicate significance
percentile = 0.05

%%%%%% No need to edit anything below this line %%%%%%%%%%%%%%%%%%%%%%%%%%%

% load the data
load(filename)

% after sorting, the values at the boundary of significance will be at
% these indices
ind_high = floor( (1-percentile)*max_iter);
ind_low = ceil( percentile*max_iter );

% find the average of actual responses (NOT bootstrapped)
actual_avg = squeeze(mean(actual,1));

% calculate psth
temp = squeeze(sum(spikes,1)); %sum across trials
b = floor( size(spikes,2)/size(actual_avg,1) ); %number of time steps in one bin
temp = reshape(temp, b,[]);
temp = sum(temp,1);
binned = reshape(temp,[],n_neurons);
%normalize to between 0 and 1 for each neuron
maxs = ones(size(binned,1),1) * max(binned);
mins = ones(size(binned,1),1) * min(binned);
binned = (binned - mins)./(maxs-mins);

% for each pair of neurons
for n1 = 1:n_neurons
    for n2 = (n1+1):n_neurons

        ind = index_lookup(n1,n2);

        figure(1)
        hold off


        % initialize variables to hold significant values
        high = zeros(max_bin,1);
        low = zeros(max_bin,1);
        
        % at each time step, find the high and low significance boundaries
        % based on the results of the bootstrapping
        for t = 1:max_bin
            temp = sort(squeeze(bootstrapped(:,t,ind)));
            high(t) = temp(ind_high);
            low(t) = temp(ind_low);
        end
        
        % plot significance levels determined from bootstrapping
        t = 0:binShift:((length(high)-1)*binShift);
        plot(t,(high-min(min(low)))/(max(max(high))-min(min(low))),':r')
        hold all
        plot(t,(low-min(min(low)))/(max(max(high))-min(min(low))),':r')

        % add the average of actual responses
        t = 0:binShift:((length(actual_avg)-1)*binShift);
        plot(t,(actual_avg(:,ind)-min(min(low)))/(max(max(high))-min(min(low))),'-b')
        
        % add psth
        t = 0:binShift:((length(binned)-1)*binShift);
        plot(t,binned(:,n1) - 2)
        plot(t,binned(:,n2) - 3)
        
        % remove tick marks on y axis. these are meaningless because
        % everything is normalized
        set(gca,'YTick',[]) 
        
        title([int2str(n1) ' vs ' int2str(n2)])
        xlabel('Time (s)')
        
        legend('95% Confidence', '     Interval','Synchrony','PSTH', 'PSTH')
        
        pause

    end
end