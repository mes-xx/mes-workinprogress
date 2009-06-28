% this file uses generates two signals where the rates and synchrony are
% independantly controllable.

rate = [50 50];  %Hz (firing rates for 2 neurons)
pSync = 0.9; %probability of synchronous firing (between 0 and 1)
delay = 6 %ms (the delay between synchronous pulses)
step = 0.3; %ms
length = 10000; %steps

% change delay so that it is in terms of steps instead of ms
delay = delay / step;

% adjust rate2 to compensate for sychronous firing
rate(2) = rate(2) - pSync .* rate(1);

% calculate parameters for poisson distribution
lambda = rate ./ 1000 .* step; %expected number of spikes per step
pFire = lambda ./ (2.71828183  .^ lambda) %probability of firing during a step

% evaluate for a firing every step using poisson distribution
count = [0 0];
for i = 1:length
    fire = rand(1, 2) <= pFire;
    if (rand(1,1) <= pSync) && (fire(1) == 1)
        fire(2) = 1;
    end
    count = count + fire; 
end

realRate = count / length / step * 1000;

disp('Rates were supposed to be ')
disp(rate)
disp(' and were actually ')
disp(realRate)