%% Example of setting states on TDT
%%%%%%%%%%%%%%%%

myState = 3;
% state is a float

% stateReady should always be low before changing state
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.stateReady'], 0);

% now change state to whatever we want
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.stateValue'], myState);

% set stateReady high so OpenEx records new state value to tank
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.stateReady'], 1);

%%%%%%%%%%%%%%%%
% remember to set stateReady low before trying to set it high again