function Neurons = neuronPropertiesFromMpars( dataFilePath )

%% Get data from .mpars file

%dataFilePath = 'F:\school\research\data\ballistic\Vrbalistic\M0109\M0109R.mpars';
% complete path to file containing data

% load data from .mpars file
rawData = load(dataFilePath);

% find the number of neurons based on the number of columns of data
[rows cols] = size(rawData);
N = cols - 4;

% get firing rate and position data from raw data
firingRates = rawData(3:end-1, 1:N);
handPosition = rawData(3:end, (cols-2):(cols) );
% last row of firing rates is skipped so that velocity (see below) and
% firingRates will have the same number of rows.

% calculate velocity and speed from positions
velocity = diff(handPosition);
speeds = sqrt(sum(velocity.^2, 2));

%% Find tuning parameters

% pick time delay (in samples)
tau = 0;

% delay the firing rates by the specified amount
delayedFiringRates = delayRows(firingRates, tau);

for n = 1:N % for each neuron

    % do the regression
    [b,bint,r,rint,stats] = ...
        regress(delayedFiringRates(:,n), ...
        [ones(size(speeds)), speeds, velocity]);

    % save parameters for later
    Neurons.Baseline(1,n)   = b(1);     % baseline
    Neurons.SpeedTuning(1,n)   = b(2);     % speed tuning

    b_xyz(:,n) = b(3:end); % direction tuning
      
end% n

b_xyz = b_xyz';

Neurons.PrefDirection = normalize(b_xyz);
Neurons.SignalScale = sqrt(sum( b_xyz.^2, 2 ));

%% Find noise parameters

% define the signal as whatever the correlation gives
signal = ones(rows-3,1)*Neurons.Baseline ...
    + speeds*Neurons.SpeedTuning ...
    + velocity*b_xyz';

% noise is everything else
noise = delayedFiringRates - signal;

% ASSUME noise is normally distributed. (this might be a bad assumption)
Neurons.NoiseScale = std(noise);

Neurons.NoiseCorrelation = corr(noise);