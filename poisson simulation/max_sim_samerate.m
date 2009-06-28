% This script uses a Poisson distribution to simulate the firings of two
% neurons. It generates a matrix 'strobe' in which each column represents
% one neuron and each row represents one step. Each element is either 0 (if
% the neuron did not fire during the step) or 1 (if the neuron did fire
% during the step). The level of synchronous firing can also be controlled.
% Each firing in the first neuron has a probability (pSync) of creating a
% simultaneous firing in the second neuron. pSync must be [0,1) and rate(2)
% >= pSync * rate(1)

    for rate = 1:50
        
        step = 0.3; %ms
        length = 167; %steps

        covars = [];
        means = [];


        % calculate parameters for poisson distribution
        lambda = rate ./ 1000 .* step; %expected number of spikes per step
        pFire = lambda ./ (exp(1)  .^ lambda); %probability of firing during a step

        % evaluate for a firing every step using poisson distribution
        for j = 1:1000
            strobe = [];
            for i = 1:length
                fire = rand(1, 1) < pFire;
                
                strobe(end+1,:) = fire;
            end %for i

            twav = strobe2twav(strobe, 33);
            c = cov(twav);
            c = c(1);
            covars(end+1) = c;
            means(end+1) = mean(covars);
            %disp(['covariance is ' num2str(c) ' and MEAN covariance is ' num2str(means(end))]);

        end %for j
        
        maxs{rate,rate} = means;
        disp(['Done with ' num2str(rate) ' versus ' num2str(rate)]);
    end %for r2


save maximum_covs maxs