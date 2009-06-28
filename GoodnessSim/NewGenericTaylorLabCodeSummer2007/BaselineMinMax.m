%data.normalized=(data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)-Parameters.meanpower)./Parameters.std2power;
% 
% %I feel like I need a loop interval in here????
% %data.normalized=Parameters.meanpower./Parameters.std2power;
% baseline=mean(data.normalized);
%     for i=1:VR.num_targets
%       min_max_normalized(i)=mean(Parameters.MeanPowerByTarget(i,:)./Parameters.std2power);
%     end
% rangeEMG=range(min_max_normalized)
% 
minEMG=min(Parameters.MeanPowerByTarget);
maxEMG=max(Parameters.MeanPowerByTarget);
%Parameters.MeanPowerByTarget(i,:)