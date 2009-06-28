% Generates typical spike trains of different synchrony levels. Typical
% means that they are close to the average synchrony value from earlier
% simulations.

thresh = 5; % maximum allowable difference (in percent) of the synchrony value of the spike train compared to the average
nrate1 =
nrate2 =
nsync  =

load avgsync
% load file with average values

sync = realmax;

while abs(sync/averaged(nsync,nrate1,nrate2) - 1) > thresh/100
    