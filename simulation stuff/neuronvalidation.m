clear all

%% User-defined parameters

totalDirections = 18;
% number of different directions to test (always uniformly distributed on sphere circle)

distances = [1 4 9];
% distance of cursor to target. useful for testing of speed encoding

ticksPerTarget = 1200;
% how many times to run GetData at each direction

neuronParameters = 'Neurons.mat';
% file containing Neurons structure with info on the neurons to test


%% Initialize some variables
load(neuronParameters, 'Neurons');
dAngle = sqrt(2*pi^2/totalDirections);
%nDimensions = size(Neurons.PrefDirection, 1);
nDirection = 0;
directions = [];


%% Test!

VR.BC_flag = 1;

% for each possible preferred direction
for distance = distances
for phi = dAngle:dAngle:2*pi
    for theta = dAngle:dAngle:pi

        nDirection = nDirection + 1
        
        % set target position someplace on circle of radius distance
        VR.target_position(1) = distance * sin(theta) * cos(phi);
        VR.target_position(2) = distance * sin(theta) * sin(phi);
        VR.target_position(3) = distance * cos(theta);
        % set cursor in the center of space
        VR.cursor_position  = [0 0 0];

        directions(end+1, :) = VR.target_position;
        
        for nTick = 1:ticksPerTarget
            %for the specified number of ticks...

            GetDataTest;
            % get the firing rates from our neurons

            data(nDirection, nTick, :) = SimData.Real;
            % save the data for later

        end
    end
end
end

% average across all ticks, so now averagedata(direction, neuron) = firing
% rate
averagedata = squeeze(mean(data,2));

inputs = [sqrt(sum(directions.^2,2)) normalize(directions)];
k0 = ones(5,1);


for n = 1:size(averagedata, 2) % for each neuron
    
    % do the fit.
    [k, residuals, jacobian] = nlinfit(inputs, averagedata(:,n), @theCurve, k0);

    fittedPrefDirs(n,:) = normalize( k(3:5)' );
    fittedBaseline(n) = k(1);
    speedTuning(n) = k(2);
end
    
Neurons.Baseline - fittedBaseline'
Neurons.PrefDirection - fittedPrefDirs

% [b,bint,r,rint,stats] = findTuningCurve(averagedata(:,1), normalize(directions));
% b'
% [Neurons.Baseline(1)   (Neurons.PrefDirection(1,:).*Neurons.SignalScale(1))]


% for nNeuron = 1:size(Neurons.PrefDirection,1)
%     firingRates = averagedata(:,nNeuron);
%     angles = acos( normalize(directions) * Neurons.PrefDirection(nNeuron,:)');
%     scatter(angles, firingRates);
%     hold on; plot(sort(angles), Neurons.Baseline(nNeuron) + Neurons.SignalScale(nNeuron).*cos(sort(angles))); hold off;
%     pause(0.2)
% end