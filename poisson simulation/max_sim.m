% This script finds the average covariance values for two strobe signals of
% varying rates when they are most synchronous. Most synchronous means that
% every time there is a fire in the first neuron there is also a fire in
% the second neuron

pSync = 1.0; %probability of synchronous firing (between 0 and 1)
delay = 0; %ms between synchronous pulses
length = 50; %ms


for r1 = 1:50
    for r2 = r1:50
        
        covars = []; 
        means = [];


        for j = 1:1000 % take 1000 samples of 50ms each
            
            strobe = simstrobe_sync(r1,r2,pSync,delay,length); %create the strobe signals
            twav = strobe2twav(strobe, 33); %transform strobes into triangle waves
            
            %take the covariance of the triangle waves
            c = cov(twav);
            c = c(2); %c(1) is the variance of the first wave, c(2) is the covariance
            
            % add this covariance to our list of covariances for this
            % rate combination
            covars(end+1) = c;
            
            % update the average covariance for this rate combination.
            % we keep a history of the means so we can make sure that they
            % are converging to some value and not just fluctuating wildly.
            means(end+1) = mean(covars);
            

        end %for j
        
        % store data from this rate combination
        maxs{r1,r2} = means;

        % output status updates so we know it is working
        disp(['Done with ' num2str(r1) ' versus ' num2str(r2)]);

    end %for r2
end %for r1

save max_data

z = mes_prepare_plot1;

surf(z);