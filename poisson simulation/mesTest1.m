% This script uses a Poisson distribution to simulate the firings of two
% neurons. It generates a matrix 'strobe' in which each column represents
% one neuron and each row represents one step. Each element is either 0 (if
% the neuron did not fire during the step) or 1 (if the neuron did fire
% during the step). The level of synchronous firing can also be controlled.
% Each firing in the first neuron has a probability (pSync) of creating a
% simultaneous firing in the second neuron. pSync must be [0,1) and rate(2)
% >= pSync * rate(1)

rate = [20 20];  %Hz (firing rates for 2 neurons)
pSync = 0.0; %probability of synchronous firing (between 0 and 1)
step = 0.3; %ms
length = 10000; %steps
strobe = [];

% adjust rate2 to compensate for sychronous firing
rate(2) = rate(2) - pSync .* rate(1);

% calculate parameters for poisson distribution
lambda = rate ./ 1000 .* step; %expected number of spikes per step
pFire = lambda ./ (exp(1)  .^ lambda); %probability of firing during a step

% evaluate for a firing every step using poisson distribution

for i = 1:length
    fire = rand(1, 2) < pFire;
    if (rand(1,1) < pSync) && (fire(1) == 1)
        fire(2) = 1;
    end
    strobe(end+1,:) = fire;
end

twav = strobe2twav(strobe, 33);
c=cov(twav(1:length,:));

disp(['covariance is ' num2str(c(2))]);