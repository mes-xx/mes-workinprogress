% This file:
%  1. Records a baseline
%  2.
%  3. Records some more to determine how far a rat can go by chance
%  4. Initialize World

disp('Initializing...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize Variables
%%%%%%%%%%%%%%%%%%%%%%

Baseline.Buffer.Covariance = [];
Baseline.Buffer.Rate = [];
Baseline.Covariance = 0;
Baseline.Rate = 0;

Trial.BlockNumber = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize TDT
%%%%%%%%%%%%%%%%

% Create ActiveX control to interact with the TDT. The ActiveX control and
% some other useful information is stored in the structure called TDT
Init_ActX;

% Turn sound off
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.CursorAmp' Parameters.ParTagSuffix], 0);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TargetAmp' Parameters.ParTagSuffix], 0);

% set some required parameters on TDT to deal with signal selection and
% filetering
for x = 1:numel(Parameters.Channels)
    invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.Chan' Parameters.ParTagSuffix int2str(x)], Parameters.Channels{x});
    invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.Sort' Parameters.ParTagSuffix int2str(x)], Parameters.SortCodes{x});
    
    if exist('Parameters.aSNIP')
        invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.aSNIP~' int2str(x)], Parameters.aSNIP{x});
    end

    if exist('Parameters.cSNIP')
        invoke(TDT.RP, TDT.call_WriteTag, [TDT.Dev{1} '.cSNIP~' int2str(x)], 0, Parameters.cSNIP{x});
    end
end

invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.RefChan' Parameters.ParTagSuffix], Parameters.RefChan);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.RefEnable' Parameters.ParTagSuffix], Parameters.RefEnable);

if exist('Parameters.HPSpike')
    invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.HPSpike' Parameters.ParTagSuffix], Parameters.HPSpike);
end
if exist('Parameters.LPSpike')
    invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.LPSpike' Parameters.ParTagSuffix], Parameters.LPSpike);
end

% Set tick period (the data is made available to MATLAB at every tick)
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TickTime' Parameters.ParTagSuffix], Parameters.TickTime);

% Set triangle width for FIR
tdtSetTriangleWidth;

% Pretend like we just read data so that we can tell when the first data is
% ready
tdtDoneReading;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Record baseline
%%%%%%%%%%%%%%%%
disp('Recording baseline...');
for i = 1:Parameters.BaselineTicks
    
    BaselineCB;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyze baseline
%%%%%%%%%%%%%%%%%%

% calculate reference values
Baseline.Covariance = mean(Baseline.Buffer.Covariance);
Baseline.Rate = mean(Baseline.Buffer.Rate);


% set initial scale factors if neccesary (scaled so that the max position
% is mapped to 2 standard deviations above the mean and the min position is
% mapped to 2 standard deviations below the mean)
if ~exist('Parameters.ScaleUp') || ~exist('Parameters.ScaleDown')
    Parameters.ScaleUp = (World.Max - World.Center) ./ (2 .* std(Baseline.Buffer.Covariance));
    Parameters.ScaleDown = Parameters.ScaleUp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save stuff to file
%%%%%%%%%%%%%%%%%%%%
save([Parameters.OutputDirectory '\environment.mat'], 'Parameters', 'Baseline', 'World');