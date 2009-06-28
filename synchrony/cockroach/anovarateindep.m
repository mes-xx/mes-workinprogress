load('C:\research\data\results20080612a.mat')

synchrony = synchrony(:,:,:,1000);

N = numel(synchrony); %total number  of measurements

y = zeros(N,1); % sync value
g1 = zeros(N,1); % firing rate 1
g2 = zeros(N,1); % firing rate 2
g3 = zeros(N,1); % number of sync spikes

siz = size(synchrony);

for ind = 1:N % for each measurement
    
    [n3 n1 n2 junk] = ind2sub(siz, ind);
    
    y(ind)  = synchrony(ind);
    g1(ind) = rates(n1);
    g2(ind) = rates(n2);
    g3(ind) = syncpersec(n3);
end

save temp g1 g2 g3 y
clear all
load temp

p = anovan(y,{g1 g2 g3},'alpha',0.01)