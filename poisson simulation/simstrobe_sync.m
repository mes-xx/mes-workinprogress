function strobe = simstrobe_sync(r1, r2, pSync, delay, length)
% simstrobe_sync(r1, r2, pSync, delay, length)
% Returns a strobe simulated by a poisson process.
%    r1     = firing rate of first neuron in Hz
%    r2     = firing rate of second neuron in Hz (r2 >= r1)
%    pSync  = probability of sychronous fire (between 0 and 1)
%    delay  = time delay between synchronous pulses in ms
%    length = length of strobe signal in ms


rate = [r1 r2];
step = 0.05; %ms

% change length from ms to steps
length = fix(length ./ step);

% adjust rate2 to compensate for sychronous firing
rate(2) = rate(2) - pSync .* rate(1);

% calculate parameters for poisson distribution
lambda = rate ./ 1000 .* step; %expected number of spikes per step
pFire = lambda ./ (exp(1)  .^ lambda); %probability of firing during a step

% evaluate for a firing every step using poisson distribution
strobe = zeros(length,2);
for n = 1:length
    strobe(n,:) = max( strobe(n,:), rand(1, 2) < pFire );
    if (strobe(n,1) == 1) && (rand(1,1) < pSync)
        strobe(n+delay,2) = 1;
    end %if
end %for i
