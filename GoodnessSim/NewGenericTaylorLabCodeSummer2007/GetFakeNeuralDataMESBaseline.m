% Give firing rates from fake neurons, taking into account closed loop
% feedback.

% I don't know what this does, but it's probably important ~MES
LoopIndex=LoopIndex+1;
TargetTally(VR.target_num)=TargetTally(VR.target_num)+1;
iTargetTally(VR.target_num)=mod(TargetTally(VR.target_num),timing.mean_windowbyTarg)+1;

% Calculate which way the cursor should move
Vel=VR.target_position;

% normalize the cursor movement direction
Vmag=sqrt(Vel*Vel'); 
% targs is the normalized velocity vector
targs=Vel/Vmag;

% The following variables should already be initialized to control the
% behavior of the fake neurons (note that nN = number of neurons and nDim =
% number of dimensions to control:
%   TDT.num_chan = nN = scalar, number of neurons to simulate
%   VR.num_dim = nDim = scalar, number of dimensions in movement space
%   Neurons.NoiseScale = 1 x nN, noise scale factor of each neuron,
%       SignalScale/NoiseScale = SNR
%   Neurons.PrefDirection = nDim x nN, preffered directions of neurons,
%       each neuron's direction should be a unit vector
%   Neurons.Baseline = 1 x nN, baseline firing rate of each neuron in APs
%       per sample
%   Neurons.SignalScale = 1 x nN, signal scale factor of each neuron in APs per sample,
%      SignalScale/NoiseScale = SNR


%expand target vector into a matrix where each row has the target position
%so we can do a dot product with each neuron
for dim = 1:VR.num_dim
    targs(2:TDT.num_chan,1) = targs(1,dim);
end

%% Find the ideal firing rates using closed loop feedback. 
% No noise or drift yet. This is the direction that the cursor should move, coded perfectly
% using preferred directions (assume cosine tuning)
SimData.Ideal = dot(Neurons.PrefDirection, targs, 2);

% Add in the proper amount of correlated noise, baseline firing rate, and
% signal levels
SimData.Real = Neurons.Baseline ...
    + Neurons.SignalScale .* SimData.Ideal ...
    + Neurons.NoiseScale .* copularnd('Gaussian', Neurons.NoiseCorrelation, 1);

% Put the data where it should be
data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)= SimData.Real;


% I don't know what this does, but it's probably important ~MES
if~mod(LoopIndex,timing.mean_update_interval)
    for i=1:VR.num_targets
        Parameters.MeanPowerByTarget(i,:)=nanmean(data.power_buffer(:,:, i));%  could concatenate additional inputs in here e.g. nanmean([data.power_buffer(:,:, i) data.rate_buff(:,:,i)]);
    end
    Parameters.meanpower=nanmean(Parameters.MeanPowerByTarget);
end
% for concatenating LFps & rates, you would need to do something similar here e.g. 
%data.normalized=([data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num) ; data.rate_buffer(iTargetTally(VR.target_num),:, VR.target_num)]-Parameters.meanpower)./Parameters.std2power;
%data.normalized=(data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)-Parameters.meanpower)./Parameters.std2power;
TDT.size_download=1;
timing.now=timing.now+timing.loop_interval;
