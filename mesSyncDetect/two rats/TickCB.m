% This subroutine is executed at every tick when running a trial
%%%%
% This file:
%  1. Reads new data from the TDT
%  2. Sets a new cursor position
%  3. Check to see if we are in the target window, and keep track of how
%     long it has been there
%  4. Write information to file
%%%%

% enable pips so that TDT alternates between target and cursor sounds
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.EnablePips' Parameters.ParTagSuffix], 1);

for tick = 1:Parameters.TicksPerTrial
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. Reads new data from the TDT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    GetData;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2. Sets a new cursor position
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UpdateCursor;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3. Check for target
    %%%%%%%%%%%%%%%%%%%%%

    % see if we are inside acceptable margin around target and keep track
    % of how long we have been there
    
    inTarget = abs(World.Cursor - World.Target) <= Parameters.HoldMargin;
    % = 1 if in target or 0 if out of target
    
    Trial.TicksInTarget = (inTarget .* Trial.TicksInTarget) + inTarget;
    % makes TicksInTarget 
    

    % if we have been at target for long enough, end the trial with success
    if Trial.TicksInTarget >= Parameters.TicksToHold
        Trial.Success = 1;
        break;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 4. Store data
    %%%%%%%%%%%%%%%
    Trial.Covariance(end + 1,:) = Data.Covariance;
    Trial.Rate(end + 1,:) = Data.Rate;
    Trial.CursorPosition(end + 1,:) = World.Cursor;

end %for

% turn off sound
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TargetAmp' Parameters.ParTagSuffix], 0);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.CursorAmp' Parameters.ParTagSuffix], 0);