Trial.BlockNumber = Trial.BlockNumber + 1;
SuccessRate = 0;

for j = 1:Parameters.TrialsPerBlock
    
    Trial.Number = j;
    
    % initialize some trial variables
    Trial.Phase = 0;
    Trial.Success = 0;
    Trial.TicksInTarget = 0;
    Trial.Covariance = [];
    Trial.Rate1 = [];
    Trial.Rate2 = [];
    Trial.CursorPosition = [];
    
    % wait for a random amount of time (5-15s) between trials (per Gage)
    pause( 10 * rand(1) + 5 );
    
    % wait for subject to hold cursor at baseline (no auditory feedback)
    World.Target = World.Center; 
    World.Cursor = World.Center;
    
    % notice that this is almost like TickCB, except there is no limit on
    % how long subject has to reach target
    while Trial.TicksInTarget < Parameters.TicksToHold
        GetData;
        UpdateCursor;
        if  abs(World.Cursor - World.Target) <= Parameters.HoldMargin
            Trial.TicksInTarget = Trial.TicksInTarget +1;
        else
            Trial.TicksInTarget = 0;
        end %if
    end %while
    
    % play target
    World.Target = Parameters.Targets( ceil( numel(Parameters.Targets) * rand(1) ) );
        % pick a target randomly from list of targets
    UpdateCursor;
    
    % disable pips so that TDT plays a solid tone
    invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.EnablePips'], 0);
    
    tdtSetSoundAmplitude(TDT, 1); % turn on sound
    pause(0.9); % let the target play for 900ms
    
    % movement time
    TickCB;
    
    % if the trial ended in success, reward the subject
    if (Trial.Success)
        GiveReward;
    end %if
    
    SuccessRate = (SuccessRate * (Trial.Number - 1) + Trial.Success) / Trial.Number;
        
    WriteTrial; %save trial data to file 
    
end %for