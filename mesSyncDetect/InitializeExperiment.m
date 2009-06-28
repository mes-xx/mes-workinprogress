% This file:
%  1. Records a baseline
%  2.
%  3. Records some more to determine how far a rat can go by chance
%  4. Initialize World


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize Variables
%%%%%%%%%%%%%%%%%%%%%%

Parameters.DataFileHandle = fopen([Parameters.OutputDirectory '\data.csv'], 'wt');
  
Baseline.Covariance = 0;
Baseline.Rate1 = 0;
Baseline.Rate2 = 0;

Baseline.Buffer.Covariance = [];
Baseline.Buffer.Rate1 = [];
Baseline.Buffer.Rate2 = [];

Trial.BlockNumber = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize TDT
%%%%%%%%%%%%%%%%

% Create ActiveX control to interact with the TDT. The ActiveX control and
% some other useful information is stored in the structure called TDT
Init_ActX;

% Turn sound off
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.CursorAmp'], 0);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TargetAmp'], 0);

% Set tick period (the data is made available to MATLAB at every tick)
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TickTime'], Parameters.TickTime);

% Set triangle width for FIR
tdtSetTriangleWidth( Parameters.TriangleWidth, 'ms');

% Pretend like we just read data so that we can tell when the first data is
% ready
tdtDoneReading;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Record baseline
%%%%%%%%%%%%%%%%

for i = 1:Parameters.BaselineTicks
    
    BaselineCB;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyze baseline
%%%%%%%%%%%%%%%%%%

% calculate reference values
Baseline.Covariance = mean(Baseline.Buffer.Covariance);
Baseline.Rate1 = mean(Baseline.Buffer.Rate1);
Baseline.Rate2 = mean(Baseline.Buffer.Rate2);

% set initial scale factors if neccesary (scaled so that the max position
% is mapped to 2 standard deviations above the mean and the min position is
% mapped to 2 standard deviations below the mean)
if ~exist('Parameters.ScaleUp') || ~exist('Parameters.ScaleDown')
    Parameters.ScaleUp = (World.Max - World.Center) / (2*std(Baseline.Buffer.Covariance));
    Parameters.ScaleDown = Parameters.ScaleUp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save stuff to file
%%%%%%%%%%%%%%%%%%%%
save([Parameters.OutputDirectory '\environment.mat'], 'Parameters', 'Baseline', 'World');