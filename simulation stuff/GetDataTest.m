% Calculate which way the cursor should move
Vel=VR.target_position-VR.cursor_position;

% If the cursor is under brain control, then normalize the cursor movement
% direction. Otherwise, move nowhere.
if VR.BC_flag
    Vmag=sqrt(Vel*Vel'); 
    % targs is the normalized velocity vector
    targs=Vel/Vmag;
else
   targs=zeros(1, VR.num_dim);
end



% The following variables should already be initialized to control the
% behavior of the fake neurons (note that nN = number of neurons and nDim =
% number of dimensions to control:
%   TDT.num_chan = nN = scalar, number of neurons to simulate
%   VR.num_dim = nDim = scalar, number of dimensions in movement space
%   Neurons.NoiseScale = 1 x nN, noise scale factor of each neuron,
%       SignalScale/NoiseScale = SNR
%   Neurons.PrefDirection = nDim x nN, preffered directions of neurons,
%       each neuron's direction should be a unit vector
%   Neurons.Baseline = 1 x nN, baseline firing rate of each neuron
%   Neurons.SignalScale = 1 x nN, signal scale factor of each neuron,
%      SignalScale/NoiseScale = SNR



%% Find the ideal firing rates using closed loop feedback. 
% No noise or drift yet. This is the direction that the cursor should move, coded perfectly
% using preferred directions (assume cosine tuning)
SimData.Ideal = Neurons.PrefDirection * targs';

% Add in the proper amount of correlated noise, baseline firing rate, and
% signal levels
% SimData.Real = Neurons.Baseline ...
%     + Neurons.SignalScale .* SimData.Ideal ...
%     + Neurons.NoiseScale .* copularnd('Gaussian', Neurons.NoiseCorrelation, 1)';
SimData.Real = Neurons.SignalScale.*SimData.Ideal + Neurons.Baseline;
%SimData.Real = SimData.Real + norminv(copularnd('Gaussian', Neurons.NoiseCorrelation, 1)', 0, Neurons.NoiseScale);