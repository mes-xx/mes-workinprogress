% run until flag is false
while KeepRunningFlag
    disp('Check signals for collecting Baseline data');
	
	% start recording
    eval(Funk.StartDSPRecord);
    VR.target_num=1;
    eval(Funk.GetData);
	
	% calculate end time for baseline collection
    TotalBaselineTimeInSamples=(timing.mean_windowbyTarg*VR.num_targets*TDT.sample_rate*timing.loop_intervalS)+timing.now;
	
	% this outer loop continues until the end time has been reached
    while timing.now<TotalBaselineTimeInSamples
		% loop through each of the targets
        for i=1:VR.num_targets
            VR.target_num=i;
            VR.target_position=VR.targets(VR.target_num,:);
            VR.in_target=1;
			
			% move the target to the current location
            eval(Funk.UpdateTargetPosition);
            vrdrawnow;
            if(TDTSet(1)=='Y')
                SendDSPFlags(TDT.RP,TDT.Dev{1}, 'TargNum', VR.target_num, TDT.FlagUpdate );
			end
			% calculate the amount of time to collect data for this target
            timing.Targ_end=timing.now+timing.max_movement_time;
			
			% read data from teh TDT and write it to file for the amt of time
			% calculated above
            while timing.now<timing.Targ_end
				% collect data
                eval(Funk.GetData);
				% write data to file
                eval(Funk.WriteLoopData);
            end

        end
    end

    if(TDTSet(1)=='Y')
        eval(Funk.PauseDSP);
	end
	% set all the Parameters to 0
    Parameters.meanpower=zeros(1,decode.num_totalchan);
    Parameters.std2power=zeros(1,decode.num_totalchan);
    Parameters.estNpower=zeros(1,decode.num_totalchan);
	
	% loop through the targets
    for i=1:VR.num_targets
		% get the indices of the NaNs in the power buffer read from the TDT
        inan=find(isnan(data.power_buffer(:,1,i))==1);
		
		% get the indices of the values taht are not NaNs in the power
		% buffer 
        inotnan=find(isnan(data.power_buffer(:,1,i))==0);
		
		% the number of good data points = the number of non NaN numbers in
		% the power buffer
        ngood=length(inotnan);
		
		% replace the NaN values with one of the randomly selected non-NaN 
		% values (we cant calculate mean or std with NaNs in the buffer)
        for j=1:length(inan)
            x=randperm(ngood);
            data.power_buffer(inan(j),:,i)=data.power_buffer(inotnan(x(1)),:,i);
            %TargetTally(i)=TargetTally(i)+1;
		end
		
		% calculate mean of the data recorded for this target and add it to
		% the mean power parameter
        Parameters.meanpower=Parameters.meanpower+nanmean(data.power_buffer(:,:,i));
		
		% calculate the std of the data recorded for this target and add it
		% to the std2power parameter
        Parameters.std2power= Parameters.std2power+2*nanstd(data.power_buffer(:,:,i));

	end
	
	% divide the meanpower and std2power parameters by the number of
	% targets to get teh true values (since we simply added all of the
	% means for each target, dividing by numTargets gets the true mean)
    Parameters.meanpower=Parameters.meanpower/VR.num_targets;
    Parameters.std2power= Parameters.std2power/VR.num_targets;
	
	% calculate estNPower -- estimate of the normalized power. For each
	% data point, we subtract the overall mean, and take the absolue value of
	% that. We then take the mean of all of those values and divide by the
	% 2* the std deviation.
    for i=1:VR.num_targets
        Parameters.estNpower=Parameters.estNpower+nanmean(abs((data.power_buffer(:,:,i)-ones(timing.mean_windowbyTarg,1)*Parameters.meanpower)));
    end
    Parameters.estNpower=Parameters.estNpower/VR.num_targets;
    Parameters.estNpower=Parameters.estNpower./Parameters.std2power
    KeepRunningFlag=0;

end

% calculate the actual frequencies for the bins we have selected to use
SigProc.FreqBinsVals=TDT.sample_rate.*SigProc.freq_bin/decode.fft_size;
fprintf(fpCO,'WeightList\n');
k=1;

 % print stuff out
for i=1:decode.num_RerefChan
    for j=1:length(SigProc.freq_bin)

        fprintf(fpCO,'%i\t%3.2f\t%f\t', i,SigProc.FreqBinsVals(j), Parameters.meanpower(k));


        fprintf(fpCO,'%f\t%f\n',   Parameters.std2power(k),Parameters.estNpower(k));
        k=k+1;
    end
end

%Calculate Expected Max and Min Powers (would it be more efficient to make
%Parameters.meanpower same length as data.power_buffer???
 width=size(data.power_buffer,2);
 EMGcolumns=size(data.power_buffer,2)-length(SigProc.freq_bin)+1;
for i=1:VR.num_targets
    for j=1:length(data.power_buffer(:,1,i))%-length(SigProc.freq_bin)+1):length(data.power_buffer(:,1,i)) 
    MeanNormalized(j,i)=mean((data.power_buffer(j,EMGcolumns:width,i)-Parameters.meanpower(1,EMGcolumns:width))./Parameters.std2power(1,EMGcolumns:width));
    end
    MeanofMeanNormalized(1,i)=mean(MeanNormalized(:,i));
end
Parameters.range=range(MeanofMeanNormalized);

% minEMG=min(Parameters.MeanPowerByTarget);
% maxEMG=max(Parameters.MeanPowerByTarget);
% Parameters.range=maxEMG-minEMG