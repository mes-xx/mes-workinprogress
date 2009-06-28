%% Example of setting states on TDT
%%%%%%%%%%%%%%%%
% This assumes you are using the coadaptive software, which should have the
% following variables defined:
%     TDT.RP = actxcontrol('TDevAcc.X');
%     invoke(TDT.RP,'ConnectServer', 'Local');
%     TDT.Dev{1}=invoke(TDT.RP,'GetDeviceName',0);
% You also need to have OpenDeveloper installed.

myInput = 123.456;
% input is a float

% Ready should always be low before changing Input
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.Ready'], 0);

% now change state to whatever we want
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.Input'], myInput);

% set stateReady high so OpenEx records new state value to tank
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.Ready'], 1);

%%%%%%%%%%%%%%%%
% remember to set Ready low before trying to set it high again