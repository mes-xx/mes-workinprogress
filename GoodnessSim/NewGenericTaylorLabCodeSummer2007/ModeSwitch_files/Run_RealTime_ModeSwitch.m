% run until flag is false
while KeepRunningFlag
%     disp('Check signals for collecting ModeSwitch data');
	
	% start recording
    eval(Funk.StartDSPRecord);
    VR.target_num=1;
    eval(Funk.GetData);
	
% 	% calculate end time for baseline collection
%     TotalBaselineTimeInSamples=(timing.mean_windowbyTarg*VR.num_targets*TDT.sample_rate*timing.loop_intervalS)+timing.now;
	
    current_block=0;
    while current_block<Parameters.MinBlocksBeforeBreak
        
        current_block=current_block+1;
        
		% loop through each of the targets
        for i=1:VR.num_targets
            VR.target_num=i;
            VR.in_target=1;
			
            %% Delay between trials
            VR.target_position=VR.movement.center;
            VR.target_position(1,1)=100000;
            eval(Funk.UpdateTargetPosition);
            vrdrawnow;
            % delay for random time btw 2-4 sec
            timing.loop_end=timing.now+timing.intertrial_interval+ceil(2*rand*TDT.sample_rate-timing.loop_interval/2);
            while timing.now<timing.loop_end,
                eval(Funk.GetData);
                eval(Funk.WriteLoopData);
            end;
            
			% move the target to the current location
            VR.target_position=VR.targets(VR.target_num,:);
            eval(Funk.UpdateTargetPosition);
            vrdrawnow;
            if(TDTSet(1)=='Y')
                SendDSPFlags(TDT.RP,TDT.Dev{1}, 'TargNum', VR.target_num, TDT.FlagUpdate );
            end

            terminate_flg=0;
            % End trial if mode switch occurs
            while terminate_flg==0
                % collect data
                eval(Funk.GetData);
                % write data to file
                eval(Funk.WriteLoopData);

                if ModeSwitch_flg==1
                    %disp('MODE SWITCH')
                    terminate_flg=1;
                end

            end

        end
    end
    
    KeepRunningFlag=0;
end % end KeepRunningFlag

