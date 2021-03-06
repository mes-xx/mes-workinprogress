%%%% Run a block of trials.

 VR.BlockNum=VR.BlockNum+1;
 disp(['Block number ' num2str(VR.BlockNum)]);
 Phit=zeros(VR.num_targets,1);
 if(VR.BlockNum>Parameters.NumBlocksEarlyLimit)
    VR.movement.earlylimit= VR.movement.limit;
end
VR.BC_flag=1; %hlc, changed from 0 to 1

timing.block_sample_start=timing.now; % overall sample that corresponds to start of block

decoding.num_trials=0; % counts number of trials
VR.target_num=0; % index of current target
VR.target_checklist=zeros(VR.num_targets,1); % records the number of times each target has been used
VR.target_checklist_init=VR.target_checklist;
VR.hit_dist=VR.TargRad+VR.CursRad; % distance between center of target and cursor when edges are touching
VR.target_position=VR.movement.center; 
%VR.target_position(1,1)=100000;
VR.cursor_position=VR.movement.center; 
%VR.cursor_position(1,1)=10000;
num_sine_waves=1; %+hlc

%% Set target ball size on the VR display
%-hlc:setfield(VR.world.Target, 'scale', [VR.TargRad VR.TargRad VR.TargRad]);
amplitude=VR.world_scale*VR.movement.range; %+hlc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Block Loop: this loop runs trials until the block is finished

while ( mean( VR.target_checklist ) < Parameters.NumTriesPerTarg ), % if mean of VR.target_checklist equals NumTargTries, current block is finished
  %while timing.now<=timing.now+VR.WavesPerTarget*(1/VR.freq) %+hlc
    %% Reset counters
    VR.in_target = 0; % this variable is set to one at the end of each update where the cursor is within the target
    timing.trial_time = 0; % this value is incremented with each sample; it is used to determine whether the current trial has timed out
    timing.in_target_time = 0; % this counts the number of samples the cursor has been within the target
%-hlc(36:44)     %% Select a target
   VR.target_num=ceil(VR.num_targets*rand);
     while VR.target_checklist(VR.target_num)==Parameters.NumTriesPerTarg,
         VR.target_num=ceil(VR.num_targets*rand);
     end;
%     %% Delay between trials
%      VR.target_position=VR.movement.center; 
%      VR.target_position(1,1)=100000;
%      VR.cursor_position=VR.movement.center; 
%    % VR.cursor_position(1,1)=10000;
%     VR.target_position=amplitude*sin(2*pi*timing.now/timing.max_movement_time); %+hlc
%     eval(Funk.UpdateTargetPosition);
%     eval(Funk.UpdateCursorPosition);
%     vrdrawnow;
    timing.loop_end=timing.now+timing.max_movement_time; %???VR.WavesPerTarget*(1/VR.Freq)
    while timing.now<timing.loop_end,
        VR.target_position=amplitude*sin(2*pi*timing.now/timing.max_movement_time);
        eval(Funk.UpdateTargetPosition);
        eval(Funk.GetData);
        eval(Funk.GetDeltaPosition);
        eval(Funk.UpdateCursorPosition);
        vrdrawnow;
        eval(Funk.WriteLoopData);
    end;
c=1
% Put cursor in center
  %  VR.cursor_position=VR.movement.center;
%    eval(Funk.UpdateCursorPosition);
%    vrdrawnow;
% Delay before target is displayed
%     timing.loop_end=timing.now+timing.target_delay;
%     while timing.now<timing.loop_end,
%         eval(Funk.GetData);
%         eval(Funk.GetDeltaPosition);
%         eval(Funk.WriteLoopData);
%         keyboard
%     end;
%    
%  
%     
% 
%     VR.target_position = [VR.world_scale*VR.targets( VR.target_num,:) ];%zeros(1,3-VR.num_dim)]; % multiply the randomly selected unit vector from target list by the distance
%     
     %% Display target
%      eval(Funk.UpdateTargetPosition);
% %         eval(Funk.UpdateHitStatus);
%      vrdrawnow;

 %% Delay before brain control
%     timing.loop_end=timing.now+timing.cursorcontrol_delay;
%     while timing.now<timing.loop_end,
%         eval(Funk.GetData);
%         eval(Funk.GetDeltaPosition);
%         eval(Funk.WriteLoopData);
%     end;
    VR.BC_flag=1;
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Brain Control Loop: this loop runs until trial times out or target is hit
    %-hlc timing.loop_end=timing.now+timing.max_movement_time;
   %-hlc while ( timing.now<timing.loop_end ) && (timing.in_target_time < timing.target_hold),
%         eval(Funk.GetData);
%         eval(Funk.GetDeltaPosition);
%         VR.cursor_position(1,[1:VR.num_dim]) = VR.cursor_position(1,[1:VR.num_dim]) + wV*TDT.size_download/TDT.sample_rate;%This is velocity * Time to get delta cursor
%         %% If cursor moves past it's max distance, move back within its limit
%         VR.cursor_dist=norm(VR.cursor_position);
%         VR.cursor_limit=norm(VR.movement.earlylimit);
%         if ( VR.cursor_dist > VR.cursor_limit )
%             VR.cursor_position=VR.cursor_position*VR.cursor_limit/VR.cursor_dist;
%         end;
%             eval(Funk.UpdateCursorPosition);
%-hlc(101:106)             eval(Funk.UpdateHitStatus);
%             if VR.in_target==1
%                 timing.in_target_time = timing.in_target_time + TDT.size_download; 
%             else
%                 timing.in_target_time=0;
%             end

    %    vrdrawnow;
%         eval(Funk.WriteLoopData);
    VR.target_checklist(VR.target_num) = Parameters.NumTriesPerTarg
   end;
  
%-hlc(111:119)    VR.BC_flag=0;
%     
%     %% Determine if trial ended successfully
     VR.target_checklist( VR.target_num ) = VR.target_checklist( VR.target_num ) + 1;
%     if ( timing.in_target_time >= timing.target_hold ), %if the trials ended because the cursor stayed in the target long enough
%         Phit(VR.target_num) = 1/VR.target_checklist(VR.target_num);
%     VR.target_checklist(VR.target_num) = Parameters.NumTriesPerTarg;
%        % disp('Its a hit!');
%    end;
    
%end;


%% Block results
%-hlc Phit = mean(Phit); % success rate of current block
Parameters.BlockTime=timing.now-timing.block_sample_start; % use number of samples for time it took to complete block

