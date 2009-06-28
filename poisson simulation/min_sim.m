% This script uses a Poisson distribution to simulate the firings of two
% neurons. It generates a matrix 'strobe' in which each column represents
% one neuron and each row represents one step. Each element is either 0 (if
% the neuron did not fire during the step) or 1 (if the neuron did fire
% during the step). The level of synchronous firing can also be controlled.
% Each firing in the first neuron has a probability (pSync) of creating a
% simultaneous firing in the second neuron. pSync must be [0,1) and rate(2)
% >= pSync * rate(1)

for r1 = 1:50

    for r2 = r1:50
        rate = [r1 r2];  %Hz (firing rates for 2 neurons)
        pSync = 0.0; %probability of synchronous firing (between 0 and 1)
        step = 0.3; %ms
        length = 30000; %steps

        covars = [];
        means = [];

        % adjust rate2 to compensate for sychronous firing
        rate(2) = rate(2) - pSync .* rate(1);

        % calculate parameters for poisson distribution
        lambda = rate ./ 1000 .* step; %expected number of spikes per step
        pFire = lambda ./ (exp(1)  .^ lambda); %probability of firing during a step

        % evaluate for a firing every step using poisson distribution
        for j = 1:1000
            strobe = [];
            for i = 1:length
                fire = rand(1, 2) < pFire;
                if (rand(1,1) < pSync) && (fire(1) == 1)
                    fire(2) = 1;
                end %if
                strobe(end+1,:) = fire;
            end %for i

            twav = strobe2twav(strobe, 33);
            c = cov(twav);
            c = c(2);
            covars(end+1) = c;
            means(end+1) = mean(covars);
            %disp(['covariance is ' num2str(c) ' and MEAN covariance is ' num2str(means(end))]);

        end %for j
        
        mins{r1,r2} = means;
        disp(['Done with ' num2str(r1) ' versus ' num2str(r2)]);
    end %for r2
    save minimum_covs mins
end %for r1

