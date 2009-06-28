%% Define some parameters
% These should be all that need to be changed for different simulations

%number of neurons
N = TDT.num_chan;

%SNR
% signal to noise ratios will be uniformly distributed between the 
% SNRs will be uniformly distributed within this range
Neurons.SNR_min = 0.5;
Neurons.SNR_max = 1.5;

%Baseline
% baseline firing rates (Hz), aka 'b' from Georgopoulos et al. 1988, will
% be uniformly distributed between the limits below
Neurons.Baseline_min = 5;
Neurons.Baseline_max = 30;

%Signal Magnitude
% maximal firing rates (Hz), aka 'k' from Georgopoulos et al. 1988, without
% baseline or noise will be uniformly distributed between the limits below
Neurons.SignalScale_min = 5;
Neurons.SignalScale_max = 30;

%Noise Correlation
% correlation coeficients between noise in different neurons, must be
% symmetrical about the main diagonal, self correlations are 1, and other
% correlation ranges from -1 to 1.
Neurons.NoiseCorrelation_min = -1;
Neurons.NoiseCorrelation_max = 1;

%% Set neuron properties
% uses parameters defined above and some probability distributions

%Signal Magnitude
% uniformly distributed signal strengths
Neurons.SignalScale = rand(1,N) * (Neurons.SignalScale_max - Neurons.SignalScale_min) + Neurons.SignalScale_min;
% adjust from APs per second (Hz) to APs per time step
Neurons.SignalScale = Neurons.SignalScale * timing.loop_intervalS;

%Noise
% noise levels based on uniformly distributed SNRs and signal levels we
% just calculated
Neurons.SNR = rand(1, N) * (Data.SNR_max - Data.SNR_min) + Data.SNR_min;
Neurons.NoiseScale = Neurons.SignalScale ./ Neurons.SNR;

%Noise Correlation
% numDim x N
% generate normally distributed random correlations, diagonal by diagonal
% must do one diagonal at a time to maintain symmetry across main diagonal
for d = 1:(TDT.num_chan - 1)
    
    % generate the diagonal of proper length
    % also, the correlations should be between -1 and 1, but randn() gives
    % numbers between 0 and 1
    corrs = (Neurons.NoiseCorrelation_max - Neurons.NoiseCorrelation_min) ...
        * randn(1, TDT.num_chan - d) ...
        + Neurons.NoiseCorrelation_min;
    
    % now put add those corrleations (on the proper diagonals above and
    % below the main diagonal) to the correlation matrix
    Neurons.NoiseCorrelation = Neurons.NoiseCorrelation ...
        + diag(corrs, d) ...
        + diag(corrs, -d);
    
end

%Baseline
% uniformly distributed baseline firing rates 
Neurons.Baseline = rand(1,N) * (Neurons.Baseline_max - Neurons.Baseline_min) + Neurons.Baseline_min;
% adjust from APs per second (Hz) to APs per time step
Neurons.Baseline = Neurons.Baseline * timing.loop_intervalS;

%Preferred Directions
% uniformly distributed (from -1 to 1) preferred directions in each
% dimension for each neuron
% numDim x N
Neurons.PrefDirection= rand(VR.num_dim, N);

% normalize each pref direction to a unit vector
for i = 1:N
	d = Neurons.PrefDirection(:, i);
	dMag = sqrt(d' * d);
	Neurons.PrefDirection(:, i) = d / dMag;
end


save([OutName 'params\Neurons.mat'],'Neurons');