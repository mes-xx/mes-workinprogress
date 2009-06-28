%GetDeltaPositionCoadaptive
%This assumes data is being normalized correctly
VR.cursor_position(1)=VR.movement.range*(mean(data.normalized(1:(length(data.normalized)-length(SigProc.freq_bin))))/Parameters.range);%plus scaling
%VR.cursor_position(1)=2*(VR.movement.range*VR.Vscale)*((mean(data.normalized))/Parameters.range);%plus scaling
% for i=1:VR.num_dim
%             PV(1,i)=(data.normalized>0).*Parameters.Wp(:,i,iUpdateBlock)'*data.normalized' +(data.normalized<0).*Parameters.Wn(:,i,iUpdateBlock)'*data.normalized';
% end
%   V=((PV-Parameters.Drift)*VR.Vscale)./Parameters.Mag(iUpdateBlock,:);%this normalizes the magnitudes along the X, Y & Z axes
% 
% wV=SigProc.CursorLowPass*V+(1-SigProc.CursorLowPass)*Vold;%this first order lowpasses the velocity data
% Vold=wV;
% if VR.BC_flag==1
%     UpdateTally=UpdateTally+1;
% 	UpdateTallyP=UpdateTallyP+(data.normalized>0)';
%     UpdateTallyN=UpdateTallyN+(data.normalized<0)';
%     Dist=VR.target_position-VR.cursor_position;
%     dEstNpower=dEstNpower+abs(data.normalized');
%     dMag=dMag + abs(PV-Parameters.Drift);
%     for i=1:VR.num_dim
%         dWp(:,i)=dWp(:,i)+(data.normalized>0)'.*((Parameters.Wp(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wp(:,1,1)))));
%         dWn(:,i)=dWn(:,i)-(data.normalized<0)'.*((Parameters.Wn(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wn(:,1,1)))));
%         dAbsErrorP(:,i)=dAbsErrorP(:,i) +abs((data.normalized>0)'.*((Parameters.Wp(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wp(:,1,1))))));
%         dAbsErrorN(:,i)=dAbsErrorN(:,i) +abs((data.normalized<0)'.*((Parameters.Wn(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wn(:,1,1))))));
%     end
% end

	
