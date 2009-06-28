% main - Top level script to run synchrony simulations

clear all

triangleWidth = 0.005; %seconds
r = 10:10:150; % firing rates
s = [0,2000,4000]; %number of synchronous spikes
%0:0.2:0.8; % synchrony levels
y = nan( length(s), length(r), length(r) ); %initialize results array

w = nan( length(s), length(r), length(r) );
x = nan( length(s), length(r), length(r) );

figure
hold all

for ii = 1:length(s)
    % for each synchrony level
    
    disp(['Beginning synchrony level ' num2str(s(ii))])
    
    for jj = 1:length(r)
        for kk = jj:length(r)
            % for each combination of firing rates
            disp(['sync ' num2str(s(ii)) ' rates ' num2str([r(jj) r(kk)])])
            
             [sync] = cps( makeSpikeTrains2([r(jj) r(kk)], s(ii)), triangleWidth);
             

             y(ii,jj,kk) = sync;
        end
    end
    
    surf(squeeze(y(ii,:,:)))
end