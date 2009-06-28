% More analysis of real data that we extracted using strobefromtank.m
close all
clear all
load('results20080611d','data');

%% calculate synchrony
stepSize = 0.001; 
offset = 0.005; 
triangleWidth = (2*1.5*(offset+stepSize/2));
binSize = 0.09;
syncs = cps4(data,triangleWidth,binSize, stepSize);

% filter syncrony
windowSize = 33; % about a 3 second sliding window
filtered = filter(ones(1,windowSize)/windowSize,1,syncs,[],3);

% show synchrony varies over range shown by simulation.  these scale
% values were found from results20080612a
sp0 = -3.8273e-005;
sp4 = 0.0067;
sp8 = 0.0134;

L = length(filtered);
t = 0:binSize:(binSize*(L-1));

% plot each pair
for row = 1:size(syncs,1)
    for col = (row+1):size(syncs,2)
        
        % this is the same for all graphs
        figure(1)
        plot(t,ones(L,1)*sp0,'--b','LineWidth',2);
        hold all
        plot(t,ones(L,1)*sp4,'--g','LineWidth',2);
        plot(t,ones(L,1)*sp8,'--r','LineWidth',2);
        legend('0 coincidences per second','4 coincidences per second','8 coincidences per second','filtered data')
        xlabel('Time, seconds')
        ylabel('Measured synchrony')
        title(['row col = ' num2str([row col])])
        
        % data for this pair
        plot(t,squeeze(filtered(row,col,:)),'-k')
        
        pause
        hold off
    end
end


%% compare to lfp

% go bin by bin