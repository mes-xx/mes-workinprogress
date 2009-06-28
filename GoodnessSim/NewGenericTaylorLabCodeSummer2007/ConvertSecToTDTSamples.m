%7-15-05 ConvertTimeToSamplesDMT must be called after sampling rate is
%calculated but before timing is used in the control loop.
fieldlist=fields(timing);

flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'loop_intervalS');
    if flag_timing
        timing.loop_interval=ceil(timing.loop_intervalS*TDT.sample_rate);
        fprintf(fpCO,'TDT.loop_interval \t%i samples\n',timing.loop_interval);
        disp('blah')
    end
end


% Time in seconds to complete movement
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'max_movement_timeS');
    if flag_timing
        timing.max_movement_time =ceil(timing.max_movement_timeS*TDT.sample_rate-timing.loop_interval/2);
        fprintf(fpCO,'timing.max_movement_time \t%i samples\n',timing.max_movement_time);
    end
end

% delay between repositioning of cursor and appearance of target
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'target_delayS');
    if flag_timing
        timing.target_delay=ceil(timing.target_delayS*TDT.sample_rate-timing.loop_interval/2);
        fprintf(fpCO,'timing.target_delay \t%i samples\n',timing.target_delay);
    end
end

% delay between trials
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'intertrial_intervalS');
    if flag_timing
        timing.intertrial_interval=ceil(timing.intertrial_intervalS*TDT.sample_rate-timing.loop_interval/2);
        fprintf(fpCO,'timing.intertrial_interval \t%i samples\n',timing.intertrial_interval);
    end
end

% delay between target appearance and BC
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'cursorcontrol_delayS');
    if flag_timing
        timing.cursorcontrol_delay =ceil(timing.cursorcontrol_delayS*TDT.sample_rate-timing.loop_interval/2);
        fprintf(fpCO,'timing.cursorcontrol_delay \t%i samples\n',timing.cursorcontrol_delay);
    end
end

% time cursor must remain in target to achieve a hit
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'target_holdS');
    if flag_timing
        timing.target_hold =ceil(timing.target_holdS*TDT.sample_rate-timing.loop_interval/2);
        fprintf(fpCO,'timing.target_hold \t%i samples\n',timing.target_hold);
    end
end

% how frequently new means are calculated in loops
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'mean_update_intervalS');
    if flag_timing
        timing.mean_update_interval = floor(ceil(timing.mean_update_intervalS*TDT.sample_rate)/timing.loop_interval);
        fprintf(fpCO,'timing.mean_update_interval \t%i Loops\n',timing.mean_update_interval);
    end
end


% amount of past data that is used to determine new means for normalization
% in loops
flag_timing=0;
for i=1:size(fieldlist,1)
    flag_timing=findstr(fieldlist{i},'mean_windowS');
    if flag_timing
        timing.mean_window =ceil(timing.mean_windowS/timing.loop_intervalS);
        fprintf(fpCO,'timing.mean_window \t%i Loops\n',timing.mean_window);
    end
end
