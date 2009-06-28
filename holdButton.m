% This script should be used with the StimCalibrate TDT circuit to train
% the rats to hold down the button for a certain amount of time  before
% receiving a reward. In OpenController, the mode must be set to manual.

%% Some parameters

% How long the button must be held down before a reward is given
holdTimeRequired = 3; %seconds

% How often the TDT is polled for data
pollInterval = 0.1; %seconds

%% Start communication with the TDT

% Make the ActiveX control
TDT.RP = actxcontrol('TDevAcc.X');
% Connect to local server
invoke(TDT.RP,'ConnectServer', 'Local');
% Get device name (needed for tag names to access parameters on pentusa)
TDT.Dev{1}=invoke(TDT.RP,'GetDeviceName',0);
TDT.Dev{2}=invoke(TDT.RP,'GetDeviceName',1);
% Determine tag names and function calls to access TDT pentusa
TDT.tag_zTime=[TDT.Dev{1} '.zTime'];
TDT.call_GetTag='GetTargetVal'; % used to access a single variable
TDT.call_ReadTag='ReadTargetV'; % used to access a sequence of data from a buffer
TDT.call_SetTag='SetTargetVal'; % used to access a single variable
TDT.call_WriteTag='WriteTargetV'; % used to access a sequence of data from a buffer

%% Main loop

buttonIsPushed = 0; % 1 when rat is holding down the button
buttonWasPushed = 0;
justStimulated = 0;
holdTime = 0; %seconds, how long the button has been held for

tic % start the timer
while 1
    
    % wait for pollInterval to elapse
    timeElapsed = toc;
    while timeElapsed < pollInterval
        timeElapsed = toc;
    end
    
    % now that poll interval has elapsed, ask the TDT if the button is
    % pushed
    buttonIsPushed = invoke(TDT.RP, TDT.call_GetTag, [TDT.Dev{1} '.SwitchStatus']);

    % start the timer again for next time
    tic
    
    % If we just gave a stimulus, the rat needs to get off of the button
    % before we can start the process again. If the button is still pushed,
    % continue to the next loop and see if he gets off of it then.
    if justStimulated && buttonIsPushed
        continue
    else
        justStimulated = 0;
    end
        
    
    % If the rat has been holding down the button, add to the hold time
    if buttonWasPushed && buttonIsPushed
        holdTime = holdTime + timeElapsed;
    end

    % remember if the button was pushed this time
    buttonWasPushed = buttonIsPushed;

    
    % If the hold time is at least as long as the required hold time, then
    % let the rat get a reward.
    if holdTime > holdTimeRequired
        % set trigger to 0, because the TDT detects the rising edge
        invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.Manual'], 0);
        % set it high to trigger stimulation
        invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.Manual'], 1);
        holdTime = 0; % reset hold time
        justStimulated = 1; % remember that the rat was just stimulated so that we can make him get off the button before stimulating him again
    end

end

invoke(TDT.RP,'CloseConnection')