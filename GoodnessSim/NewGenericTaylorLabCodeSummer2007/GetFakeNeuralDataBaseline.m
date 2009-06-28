%Fake data maker for 2 neurons, one codes for X and one codes for y
%%'unequal informaiton in X vs. Y  with Correlations and asymmetry in Y'

%This simulates closed loop control in that it make the endcoded movement
%from the actual needed movement at each timepoint.

LoopIndex=LoopIndex+1;
TargetTally(VR.target_num)=TargetTally(VR.target_num)+1;
iTargetTally(VR.target_num)=mod(TargetTally(VR.target_num),timing.mean_windowbyTarg)+1;
Vel=VR.target_position;

Vmag=sqrt(Vel*Vel');
targs=Vel/Vmag;



% A=.05; %variance (noise) in X 
% B=.05; % variance (noise) in Y
% C=0.04; %information in X 
% D=0.01; % information in Y
% Pcor=.5 % zero implies noise is independent; 1 implies noise in X=noise in Y
% ASymScaleX=1
% ASymScaleY=2.5


rand('state',sum(100*clock));
info = (Neurons.PrefDirection' * targs')';
noise = Neurons.NoiseScale .* (rand(1, N) * Neurons.Correlation);
%     noiseX=A*randn(1);
%     Xinfo=C*targs(:,1);
%     Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
%     
%     Yinfo=D*targs(:,2);
%     Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
%     Nxx=[Xinfo + noiseX]
%     Nyy=[Yinfo + (1-Pcor)*B*randn + Pcor*noiseX]
    
     data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)=noise + info;
if~mod(LoopIndex,timing.mean_update_interval)
    for i=1:VR.num_targets
        Parameters.MeanPowerByTarget(i,:)=nanmean(data.power_buffer(:,:, i));%  could concatenate additional inputs in here e.g. nanmean([data.power_buffer(:,:, i) data.rate_buff(:,:,i)]);
    end
    Parameters.meanpower=nanmean(Parameters.MeanPowerByTarget);
end
% for concatenating LFps & rates, you would need to do something similar here e.g. 
%data.normalized=([data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num) ; data.rate_buffer(iTargetTally(VR.target_num),:, VR.target_num)]-Parameters.meanpower)./Parameters.std2power;
%data.normalized=(data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)-Parameters.meanpower)./Parameters.std2power;
TDT.size_download=1;

timing.now=timing.now+timing.loop_interval;
