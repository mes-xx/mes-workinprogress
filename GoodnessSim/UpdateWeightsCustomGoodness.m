%Update_weightsDMT
fprintf(fpCO,'%f\t %f\n', Parameters.BlockTime(iUpdateBlock), Parameters.EndDistance(iUpdateBlock), Parameters.Phit(iUpdateBlock));

%Adjust cursor radius
if((Parameters.Phit(iUpdateBlock)>Parameters.MaintainPercentHit)&& (VR.TargRad>VR.MinTargRad))
    VR.TargRad=VR.TargRad-VR.TargRdStepSize;%Note you would need to adjust cursor too in pacman game
elseif((Parameters.Phit(iUpdateBlock)<Parameters.MaintainPercentHit)&& (VR.TargRad<VR.MaxTargRad))
    VR.TargRad=VR.TargRad+VR.TargRdStepSize;%Note you would need to adjust cursor too in pacman game
end
VR.hit_dist=VR.TargRad+VR.CursRad;
Parameters.RadAdjust=VR.TargRad;

% Sbest determination used to be here, but it has been moved to after the
% error calculations so that it can use error magnitude and consistency in
% its calculations

iBlockOld=iUpdateBlock;
UpdateBlockNum=UpdateBlockNum+1;

iUpdateBlock=mod(UpdateBlockNum+Parameters.NumBlocksHeld-1,Parameters.NumBlocksHeld)+1;


% Ps calculation was here, but moved to after Sbest determination

meanphit=mean(Parameters.Phit);
Ao   = Parameters.Amax - (meanphit* Parameters.Ca2* Parameters.Amax); % Alpha
%scalenZ[i]=errnZ[i]/dMCnz[i];==AbsMeanErrorP/MeanAbsErrorP

% calculate dWxpi and dWxni (MeanErrorP, MeanErrorN)
MeanErrorP=dWp./(UpdateTallyP*ones(1,VR.num_dim));%dCpx[i]/(float) countdC===DWxpi(S)  = Ek[Wxpi(k)NRi(k) –(Tx(k)-Cx(k))]
MeanErrorN=dWn./(UpdateTallyN*ones(1,VR.num_dim));

% AbsMeanError == absolute value of MeanErrorP and MeanErrorN and will be
% used to calculate EMxpi and ECxpi
AbsMeanErrorP=abs(MeanErrorP);% errp    %total num decode channels x num dim
AbsMeanErrorN=abs(MeanErrorN);%total num decode channels x num dim

% MeanAbsError ==> Ek[ |Wxpi(k)NRi(k) - (Tx(k)-Cx(k)) | ]
MeanAbsErrorP=dAbsErrorP./(UpdateTallyP*ones(1,VR.num_dim));%dMCp
MeanAbsErrorN=dAbsErrorN./(UpdateTallyN*ones(1,VR.num_dim));

% make sure MeanAbsError is non zero everywhere since it will be a
% denominator in upcoming calculations
MeanAbsErrorP(find(MeanAbsErrorP< .0001))=.0001;
MeanAbsErrorN(find(MeanAbsErrorN< .0001))=.0001;

% Calculate error magnitude measure and Error consistency measure
EMp=AbsMeanErrorP;%errp
EMn=AbsMeanErrorN;
ECp=AbsMeanErrorP./MeanAbsErrorP;             
ECn=AbsMeanErrorN./MeanAbsErrorN; %scalen


% normalize EMp to values between -1 and 1
NEMp=(EMp-ones(size(EMp(:,1)))*median(EMp))./(2*ones(size(EMp(:,1)))*mean( abs((EMp-ones(size(EMp(:,1)))*median(EMp)))));
NEMp(find(NEMp>1))=1;
NEMp(find(NEMp<-1))=-1;
NEMp(find(isnan(NEMp)==1))=eps(0);

% normalize EMn to values between -1 and 1
NEMn=(EMn-ones(size(EMn(:,1)))*median(EMn))./(2*ones(size(EMn(:,1)))*mean( abs((EMn-ones(size(EMn(:,1)))*median(EMn)))));
NEMn(find(NEMn>1))=1;
NEMn(find(NEMn<-1))=-1;
NEMn(find(isnan(NEMn)==1))=eps(0);

% normalize ECp to values between -1 and 1
NECp=(ECp-ones(size(ECp(:,1)))*median(ECp))./(2*ones(size(ECp(:,1)))*mean( abs((ECp-ones(size(ECp(:,1)))*median(ECp)))));
NECp(find(NECp>1))=1;
NECp(find(NECp<-1))=-1;
NECp(find(isnan(NECp)==1))=eps(0);

% normalize ECn to values between -1 and 1
NECn=(ECn-ones(size(ECn(:,1)))*median(ECn))./(2*ones(size(ECn(:,1)))*mean( abs((ECn-ones(size(ECn(:,1)))*median(ECn)))));
NECn(find(NECn>1))=1;
NECn(find(NECn<-1))=-1;
NECn(find(isnan(NECn)==1))=eps(0);


%Find Sbest -- the block that the subject performed the best on --
eval(Funk.BestByGoodness);

% prevent a zero value in the next calculation by setting a min value for
% phitmax
phitmax=Parameters.Phit(iBest);
if((Parameters.Phit(iBest)+Parameters.Phit(iBlockOld))<0.01)
    phitmax=0.01;
end

% calculates 1 - Ps
partold=phitmax/(phitmax+Parameters.Phit(iBlockOld)+0.01);
partold=1-((1-partold)*(1-(0.97*(phitmax-Parameters.Phit(iBlockOld)))));

% set a max value for 1-Ps
if(partold>0.98)
    partold=0.98;
end
      





% update Ap values based on normalized EMp and ECp values
Ap = Ao*( 1 + Parameters.Ca1*(NEMp + NECp) ) ;%(1.0+(Dev_Adjust*(errpX[i]+scalepX[i])))*Alpha*

% update An values based on normalized EMn and ECn values
An = Ao*( 1 + Parameters.Ca1*(NEMn + NECn) ) ;

% update Bp values based on the expected value for Phit and normalized ECp, EMp
Bp=1+Parameters.Cb*(1-meanphit)*(NECp-NEMp);%(1.0+(Full_Adjust*(scalepY[i]-errpY[i])*(1.0f-meanphit)))===1 + CBBo(N[ECxpi(S)]- N[EMxpi(S)])  where Bo= 1 - En[Phit(n)]   (n: S-0, S-1,...,S-N+1)

% update Bn values based on the expected value for Phit and normalized ECn,
% EMn
Bn=1+Parameters.Cb*(1-meanphit)*(NECn-NEMn);

%Cp[i][0][iset]=(((Cp[i][0][isetold]-((1.0+(Dev_Adjust*(errpX[i]+scalepX[i])))*Alpha*dCpx[i]/(float) countdC))*(1.0f-partold))+(partold*Cp[i][0][iPhitmax]))*(1.0+(Full_Adjust*(scalepX[i]-errpX[i])*(1.0f-meanphit)));

% update Wp and Wn (pg 223 in appendix A)
Parameters.Wp(:,:,iUpdateBlock)=Bp.*(((1-partold)*(Parameters.Wp(:,:,iBlockOld)-Ap.*MeanErrorP)) + (partold*Parameters.Wp(:,:,iBest)));%Cp[i][0][iset]=(((Cp[i][0][isetold]-((1.0+(Dev_Adjust*(errpX[i]+scalepX[i])))*Alpha*dCpx[i]/(float) countdC))*(1.0f-partold))+(partold*Cp[i][0][iPhitmax]))*(1.0+(Full_Adjust*(scalepX[i]-errpX[i])*(1.0f-meanphit)));
Parameters.Wn(:,:,iUpdateBlock)=Bn.*(((1-partold)*(Parameters.Wn(:,:,iBlockOld)-An.*MeanErrorN)) + (partold*Parameters.Wn(:,:,iBest)));


% for each channel and each dimension, calculate drift according to the
% equation on pg 219 of appendix A
Parameters.Drift=zeros(1,VR.num_dim);
Parameters.estNpower=dEstNpower/UpdateTally;
for i=1:decode.num_totalchan
		
    for j=1:VR.num_dim
		Parameters.Drift(1,j)=Parameters.Drift(1,j)+Parameters.Wp(i,j,iUpdateBlock)*0.5*Parameters.estNpower(i) - Parameters.Wn(i,j,iUpdateBlock)*0.5*Parameters.estNpower(i);
    end
end

% adjust the mag parameter based on the current weights adjusted for errors seen in recent
% blocks and based on weights that produced the best results
Parameters.Mag(iUpdateBlock,:)=dMag/UpdateTally*(1-partold) + partold*Parameters.Mag(iBest,:);
%Parameters.RMag(iUpdateBlock,:)=dRMag/UpdateTally*(1-partold) + partold*Parameters.RMag(iBest,:);

% reset all of the values that accumulate over the entire set of blocks
% before another update
dEstNpower=zeros(decode.num_totalchan,1);%This Sums normalized power for weight update
dWp=zeros(decode.num_totalchan,VR.num_dim);%This Sums errors for weight update
dWn=zeros(decode.num_totalchan,VR.num_dim);%This Sums errors for weight update
dMag=zeros(1,VR.num_dim); %This sums magnitude of movements in each direction
%dRMag=zeros(1,VR.num_dim); %This sums rotation magnitude of movements in each direction
dAbsErrorP=zeros(decode.num_totalchan,VR.num_dim);
dAbsErrorN=zeros(decode.num_totalchan,VR.num_dim);
UpdateTally=0;
UpdateTallyP=ones(decode.num_totalchan,1)*eps(0);
UpdateTallyN=ones(decode.num_totalchan,1)*eps(0);
k=1;
for i=1:decode.num_RerefChan
    for j=1:length(SigProc.freq_bin)
    
        for n=1:VR.num_dim
            fprintf(fpCO,'%f\t',  Parameters.Wp(k,n,iUpdateBlock));
        end
        for n=1:VR.num_dim
            fprintf(fpCO,'%f\t',  Parameters.Wn(k,n,iUpdateBlock));
        end
        fprintf(fpCO,'%f\n',   Parameters.estNpower(k));
        k=k+1;
    end
end
% print stuff out
fprintf(fpCO,'999999999\t')
for n=1:VR.num_dim
       fprintf(fpCO,'%f\t',  Parameters.Drift(n));
 end
for n=1:VR.num_dim
       fprintf(fpCO,'%f\t',  Parameters.Mag(iUpdateBlock , n));
end
 fprintf(fpCO,'%i\t%i\t%f\t', Parameters.RadAdjust,iBest,partold);