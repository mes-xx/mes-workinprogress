%%
% Find preferred directions given velocity and firing rates from data from
% a ballistic task that Dawn recorded many years ago. This script uses a
% varaibles that are created by ComparePathsforfig2.m and also uses info
% from the cursor file

%% User-defined variables
% The user must define stuff here.

% Number of neurons. Maybe one day this will be automated. For now, you
% need to look in the appropriate .cen_out file, under 'Parameters' and
% count the number of lines underneath it. Each line of data corresponds to
% one neuron
N = 59;

% Name of variable containing data from cursor file.
cursorFileData = load('F:\school\research\data\ballistic\Vrbalistic\M0109\M0109R04.cursor');;

% Different values  of time delays to try when looking for the best
% correlation between firing rates and movements. These are in the units of
% timesteps, but I don't know how to find out how big each timestep is.
timeDelayRange = 0:5;

%% Initialize other variables


% A vector of hand positions should be stored in HCposinterp after running
% ComparePathsforfig2.m. Use the differences between positions to get the
% velocity vector.
velocity = diff(HCposinterp);

% Crop the cursor file data just like ComparePathsforfig2.m does, so that
% the firing rates and hand positions match up.
[r c] = size(cursorFileData);
r = r - 2;
getstart=find(abs(diff(cursorFileData(1:1000,c-7)))>(200));
if(isempty(getstart))
    start = 1;
else
    start = getstart(1)+1;
end
cursorFileData = cursorFileData(start:r,:);

%DEBUG
cursorFileData = cursorFileData(10000:20000,:);
velocity = velocity(10000:19999,:);

% Get instantaneous and mean firing rates from cursorFileData. Firing rate
% data is in the first 2N columns of the cursor data. Every odd column is
% the instantaneous firing rate and every even column is a mean firing
% rate. 
firingRates = (cursorFileData(:,1:2:2*N));
meanFiringRates = (cursorFileData(:,2:2:2*N));

% Also, do a square root transform.
firingRates = sqrt(firingRates);

%% Find optimum time delay
% Find the time delay that maximizes the correlation between neural
% activity and movements

for j = 1:length(timeDelayRange) % for each possible delay...
    timeDelay = timeDelayRange(j);
    
    % delay firing rates using a custom function
    delayedFiringRates = delayRows(firingRates, timeDelay);
    

    % Note that some rows in velocity will be NaN because the hand position
    % was out of range of the Optotrack (and maybe for other reasons too),
    % but findTuningCurve() below excludes these from the regression.
    
    % Perform the regression, leaving off the last row of firing rates to
    % make the lengths of the two matrices the same.
    [b,bint,r,rint,stats] = findTuningCurve2(delayedFiringRates(1:end-1,:), velocity);
    
    % record the average correlation coefficient, R^2 = stats(1) for later
    for k = 1:length(stats)
        temp(k) = stats{k}(1);
    end % k
    allR(j) = mean(temp);
    
end % j

% Find the time delay that gives the maximum correlation
j = find( allR == max(allR) );
disp(['Best time delay is ' num2str(timeDelayRange(j)) ' with R=' num2str(allR(j))]);

% Plot regression coefs vs. time delay and show location of max R so user
% can see that this optimization worked. 
figure;
scatter(timeDelayRange, allR);
hold on;
scatter(timeDelayRange(j), allR(j), 'x');
xlabel('Time delay');
ylabel('Average Correlation Coefficient');
hold off;

%% Find preferred direction
% Redo the regression using the optimal time delay

delayedFiringRates = delayRows(firingRates, timeDelayRange(j));
[b,bint,r,rint,stats] = findTuningCurve2(delayedFiringRates(1:end-1,:), velocity);

%% Plot preferred directions on unit sphere
% x=[];
% y=[];
% z=[];
% 
% for j = 1:N
%     x(j) = b{j}(2);
%     y(j) = b{j}(3);
%     z(j) = b{j}(4);
%     
%     mag(j) = sqrt( x(j).^2 + y(j).^2 + z(j).^2 );
%     x(j) = x(j) ./ mag(j);
%     y(j) = y(j) ./ mag(j);
%     z(j) = z(j) ./ mag(j);
% end % j
% 
% figure;
% scatter3(x,y,z);
% title('Preferred directions (normalized to unit sphere)');
% xlabel('x');
% ylabel('y');
% zlabel('z');

b_n = [];

for j = 1:N
    b_n(j) = bint{j}(2);
end

figure;
hist(b_n,20)
title('Speed tuning')
ylabel('Number of neurons')
xlabel('Tuning intensity')

for j = 1:N
    Rsquared(j) = stats{j}(1);
end

figure;
hist(Rsquared,20)
title('R^2 values')

for j = 1:N
    b_0(j) = b{j}(1);
    b_n(j) = b{j}(2);
    b_xyz(j,:) = b{j}(3:5);
end

figure;
hist(b_0,20)
title('b_0')
