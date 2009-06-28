function strobe = simstrobe(rate, length)
% simstrobe_sync(r1, r2, pSync, delay, length)
% Returns a strobe simulated by a poisson process.
%    rate   = row vector of firing rates in Hz
%    length = length of strobe signal in ms


step = 0.05; %ms
nCells = size(rate, 2);

% change length from ms to steps
length = fix(length ./ step);

% calculate parameters for poisson distribution
lambda = rate ./ 1000 .* step; %expected number of spikes per step
pFire = lambda ./ (exp(1)  .^ lambda); %probability of firing during a step

% evaluate for a firing every step using poisson distribution
for n = 1:length
    strobe(n,:) = ( rand(1, nCells) < pFire );
end %for i
