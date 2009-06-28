set(VR.fig,'NavPanel','none');
vrdrawnow;
VR.fig
swich = 0;
pause(1)
eval(Funk.StartDSPRecord);
HiResTimer('StartTimer');
timing.now = 0;
while KeepRunningFlag 
% This section runs one or more blocks of movements until it is time to
% update the weights. Weights are updated after one or more blocks depending on how many were set in the configuration file.
% It also keeps track of the hit rate (Phit) and the
% time it took to complete each block (BlockTime). The averages of these
% are printed out after each weight update
    Parameters.Phit(iUpdateBlock)=0 % success rate of current block
    Parameters.BlockTime(iUpdateBlock)=0; % use number of samples for time it took to complete block
    Parameters.EndDistance(iUpdateBlock)= 0;
    for i= 1:Parameters.NBlocksPerUpdate
        eval(Funk.RunBlock); % This runs one complet block of movements to all targets
        Parameters.Phit(iUpdateBlock)=Parameters.Phit(iUpdateBlock) +Phit;%; % success rate of current block
        Parameters.BlockTime(iUpdateBlock)=Parameters.BlockTime(iUpdateBlock) +BlockTime;% use number of samples for time it took to complete block
  %      Parameters.EndDistance(iUpdateBlock)= Parameters.EndDistance(iUpdateBlock)+ EndDistance;
    end
    Parameters.Phit(iUpdateBlock)=Parameters.Phit(iUpdateBlock)/Parameters.NBlocksPerUpdate ;
    Parameters.BlockTime(iUpdateBlock)= Parameters.BlockTime(iUpdateBlock)/Parameters.NBlocksPerUpdate;
 %   Parameters.EndDistance(iUpdateBlock)= Parameters.EndDistance(iUpdateBlock)/Parameters.NBlocksPerUpdate;
% this function updates the weights using values accumulated throughout the last one or more blocks.
    save([OutName 'params\Parameters' num2str(UpdateBlockNum)], 'Parameters');
  %  eval(Funk.UpdateDecoder);
  
%==========================================================================
%=======================================================================
% allows you to stop or continue after a certain number of blocks.
    if ~mod(VR.BlockNum,Parameters.MinBlocksBeforeBreak)
%         if strcmp(questdlg('Adjust for Correlations?'),'Yes')    
%            eval(Funk.FixCorrelations);
%         end
        if ~strcmp(questdlg('Continue testing?'),'Yes')
            KeepRunningFlag=0;
            TDT.last_index=-1;
            fprintf(fpCO,'%f\t %f\n', Parameters.BlockTime(iUpdateBlock), Parameters.EndDistance(iUpdateBlock), Parameters.Phit(iUpdateBlock));
        end
        
       if strcmp(questdlg('Go to keyboard?'),'Yes')
           keyboard
       end
       pause(1);
    end
end;%While running blocks

% set all the Parameters to 0
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

    % calculate the std of the data recorded for this target and add it
    % to the std2power parameter
    Parameters.std2power= Parameters.std2power+2*nanstd(data.power_buffer(:,:,i));

end

% divide the meanpower and std2power parameters by the number of
% targets to get teh true values (since we simply added all of the
% means for each target, dividing by numTargets gets the true mean)
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