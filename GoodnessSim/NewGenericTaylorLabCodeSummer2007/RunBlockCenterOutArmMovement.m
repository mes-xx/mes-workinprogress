%%%% Run a block of trials.

 VR.BlockNum=VR.BlockNum+1;
 disp(['Block number ' num2str(VR.BlockNum)]);
 Phit=zeros(VR.num_targets,1);
 if(VR.BlockNum>Parameters.NumBlocksEarlyLimit)
    VR.movement.earlylimit= VR.movement.limit;
end
VR.BC_flag=0;

timing.block_sample_start=timing.now; % overall sample that corresponds to start of block

decoding.num_trials=0; % counts number of trials
VR.target_num=0; % index of current target
VR.target_checklist=zeros(VR.num_targets,1); % records the number of times each target has been used
VR.target_checklist_init=VR.target_checklist;
VR.CursRad = VR.TargRad;
VR.hit_dist=VR.TargRad+VR.CursRad; % distance between center of target and cursor when edges are touching
VR.target_position=VR.movement.center; 
VR.target_position(1,1)=100000;
VR.cursor_position=VR.movement.center; 
VR.cursor_position(1,1)=10000;


%% Set target ball size on the VR display
setfield(VR.world.Target, 'scale', [VR.TargRad VR.TargRad VR.TargRad]);
setfield(VR.world.Cursor, 'scale', [VR.TargRad VR.TargRad VR.TargRad]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Block Loop: this loop runs trials until the block is finished
centerTarget = 1;

while ( mean( VR.target_checklist ) < Parameters.NumTriesPerTarg ), % if mean of VR.target_checklist equals NumTargTries, current block is finished

    %% Reset counters
    VR.in_target = 0; % this variable is set to one at the end of each update where the cursor is within the target
    timing.trial_time = 0; % this value is incremented with each sample; it is used to determine whether the current trial has timed out
    timing.in_target_timeS = 0; % this counts the number of samples the cursor has been within the target
    %% Select a target
    VR.target_num=ceil(VR.num_targets*rand);
    while VR.target_checklist(VR.target_num)==Parameters.NumTriesPerTarg,
        VR.target_num=ceil(VR.num_targets*rand);
    end;
    %% Delay between trials
    VR.target_position=VR.movement.center; 
    VR.target_position(1,1)=100000;
   % VR.cursor_position=VR.movement.center; 
   % VR.cursor_position(1,1)=10000;
    eval(Funk.UpdateTargetPosition);
   % eval(Funk.UpdateCursorPosition);
    vrdrawnow;
     timing.loop_endS=timing.now+timing.intertrial_intervalS;
    while timing.now<timing.loop_endS,
        eval(Funk.GetData);
        eval(Funk.GetDeltaPosition);
        eval(Funk.WriteLoopData);
     end;
% Put cursor in center
    %VR.cursor_position=VR.movement.center;
    %eval(Funk.UpdateCursorPosition);
   vrdrawnow;
%% Delay before target is displayed
    timing.loop_endS=timing.now+timing.target_delayS;
    while timing.now<timing.loop_endS,
        eval(Funk.GetData);
        eval(Funk.GetDeltaPosition);
        eval(Funk.WriteLoopData);
     
        
    end;
   
 
    

    VR.target_position = [VR.world_scale*VR.targets( VR.target_num,:) ];%zeros(1,3-VR.num_dim)]; % multiply the randomly selected unit vector from target list by the distance
    if (centerTarget == 1)
        
        VR.target_position = VR.movement.center;
    end
    centerTarget = 1 - centerTarget;
    
    %% Display target
    eval(Funk.UpdateTargetPosition);
    eval(Funk.UpdateHitStatus);
    vrdrawnow;
    
   

 %% Delay before brain control
    timing.loop_endS=timing.now+timing.cursorcontrol_delayS;
    while timing.now<timing.loop_endS,
        eval(Funk.GetData);
        eval(Funk.GetDeltaPosition);
        eval(Funk.WriteLoopData);
        
    end;
    VR.BC_flag=1;
    TDT.ToneFreq = TDT.ToneFreqReset;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Brain Control Loop: this loop runs until trial times out or target is hit
    timing.loop_endS=timing.now+timing.max_movement_timeS;
    while ( timing.now<timing.loop_endS ) && (timing.in_target_timeS < timing.target_holdS),
        ReadOptotrakCenterFile;
        eval(Funk.GetData);
        eval(Funk.GetDeltaPosition);
        eval(Funk.UpdateHitStatus);
        if VR.in_target==1
            timing.in_target_timeS = timing.in_target_timeS + VR.loopTime; 
            PlayOnTarget;
        else
            timing.in_target_timeS=0;
            TDT.ToneFreq = TDT.ToneFreqReset;
        end
        vrdrawnow;
        eval(Funk.WriteLoopData);
   end;
   VR.BC_flag=0;
    
    %% Determine if trial ended successfully
    VR.target_checklist( VR.target_num ) = VR.target_checklist( VR.target_num ) + 1;
    if ( timing.in_target_timeS >= timing.target_holdS ), %if the trials ended because the cursor stayed in the target long enough
        Phit(VR.target_num) = 1/VR.target_checklist(VR.target_num);
        VR.target_checklist(VR.target_num) = Parameters.NumTriesPerTarg;
        if (centerTarget == 1)
            DispenseReward;
        else
            if rand(1) > 0.8
                DispenseReward;
            end
        end
       % disp('Its a hit!');
   end;
    
end;


%% Block results
Phit = mean(Phit); % success rate of current block
BlockTime=timing.now-timing.block_sample_start; % use number of samples for time it took to complete block

