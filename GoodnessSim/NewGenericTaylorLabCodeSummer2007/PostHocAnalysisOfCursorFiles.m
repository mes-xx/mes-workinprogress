%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is offline code to optimize the folling parameters by re-evaluating a
%cursor file using these different parameters over their ranges
%Error angle (in abs value) is calculated at each time step and averaged
%across blocks. Weights start in the same place, but then are independently
%recalculated after each block. Current version doesNOT recalculate Phit or Blocktime based on new data.
%Below are the parameters spaned and the value ranges suggested in
%dissertation.
% Parameters.Ca1            0.23 ...0.05 to 0.4
% Parameters.Ca2            0.80..between 1 and 0
% Parameters.Amax           0.15...used from 0.15 to 0.45
% Parameters.Cb             0.25...0.0 and 0.5
%MeanErrorAngle i s calculated in dimensions length(Ca1List), length(Ca2List), length(AmaxList), length(CbList) num blocks in ;
% it is saved after every combination of parameters is tested allong with
% iii,jjj,kkk,lll so as to know where you left off if you crash out.

close all
clear all
Ca1List=0.05:.1:0.5;
Ca2List=0.05:.2:1;
AmaxList=0.05:.1:0.5;
CbList=0.05:.1:0.5;

CursFileName='C:\Data\Debug\TST062207\TST06220703.cursor'
%  [CursFileName PATHNAME, FILTERINDEX] = uigetfile('*.cursor','get cursor file to analyze');%'C:\Apanius\Matlab Code\DMTsEEG_Coadaptive_Flex_5-10\DMT_EEGCoadaptive.config';
%  CursFileName=[ PATHNAME CursFileName];
NCycles=  length(Ca1List)*length(Ca2List) *length(CbList)  *length(AmaxList);
CycleCount=0;
tic
for iii=length(Ca1List):-1:1
    Ca1=Ca1List(iii);
    for jjj=length(Ca2List):-1:1
        Ca2=Ca2List(jjj);
        for kkk=length(AmaxList):-1:1
            Amax=AmaxList(kkk);
            for lll=length(CbList):-1:1
                Cb=CbList(lll);

               [fCursIn message]=fopen(CursFileName,'r');
                if(fCursIn==-1)
                    disp(['ERROR: Could not open'  CursFileName]);
                    disp(message);
                    KeepRunningFlag=0;
                else

                    ParamFileBaseName=[CursFileName(1:length(CursFileName)-7) 'params\Parameters'];

                    Start=load([ParamFileBaseName 'Start']);
                    CursorFileColumnRecord=Start.VR.CursorColumnRecord;
                    decode.num_totalchan=Start.decode.num_totalchan;
                    VR.num_dim=Start.VR.num_dim;
                    Parameters=Start.Parameters;
                    VR.Vscale=Start.VR.Vscale;
                    Parameters.Ca1=Ca1List(iii);
                    Parameters.Ca2=Ca2List(jjj);
                    Parameters.Amax=AmaxList(kkk);
                    Parameters.Cb=CbList(lll);

                    for q=1:size(CursorFileColumnRecord,1);

                        line=CursorFileColumnRecord{q,2};
                        if ~isempty(findstr(line,'VR.target_position'))==1
                            Ctarget_position=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'VR.cursor_position'))==1
                            Ccursor_position=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'VR.BC_flag'))==1
                            CBC_flag=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'data.normalized'))==1
                            Cdata.normalized=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'UpdateBlockNum'))==1
                            CUpdateBlockNum=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'LoopIndex'))==1
                            CLoopIndex=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'VR.BlockNum'))==1
                            CBlockNum=CursorFileColumnRecord{q,1};
                        elseif ~isempty(findstr(line,'VR.target_num'))==1
                            Ctarget_num=CursorFileColumnRecord{q,1};
                        end
                    end
                    %Stuff to be initialized at the start==============
                    VR.BlockNum=1; %% counts number of blocks during recording session
                    UpdateBlockNum=1; %Counts the number of times the weights are updated
                    iUpdateBlock=mod(UpdateBlockNum+Parameters.NumBlocksHeld-1,Parameters.NumBlocksHeld)+1;
                    timing.now=0;%In samples
                    TDT.size_download=1;
                    %wV=zeros(1,VR.num_dim);
                    %data.normalized=zeros(size(Parameters.meanpower));
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

                    oldUpdateBlockNum=1;
                    erroranglesum=0;
                    TallyErrorAngle=0;
                    while(line~=-1)
                        line=fgetl(fCursIn);
                        if line~=-1
                            line=str2num(line);
                            VR.BC_flag=line(CBC_flag(1):CBC_flag(2));
                            if(VR.BC_flag==1)
                                LoopIndex=line(CLoopIndex(1):CLoopIndex(2));
                                UpdateBlockNum=line(CUpdateBlockNum(1):CUpdateBlockNum(2));
                                data.normalized=line(Cdata.normalized(1):Cdata.normalized(2));
                                VR.target_position=line(Ctarget_position(1): Ctarget_position(2));
                                VR.cursor_position=line(Ccursor_position(1): Ccursor_position(2));
                                VR.BlockNum=line(CBlockNum(1): CBlockNum(2));
                                VR.target_num=line(Ctarget_num(1): Ctarget_num(2));
                            end
                            %  keyboard

                            if oldUpdateBlockNum~=UpdateBlockNum %Read in updated parameter values except weights
                                oldUpdateBlockNum=UpdateBlockNum;
                                if oldUpdateBlockNum>0
                                    MeanErrorAngle(oldUpdateBlockNum,iii, jjj, kkk,lll)= erroranglesum/TallyErrorAngle;
                                end
                                erroranglesum=0;
                                TallyErrorAngle=0;
                                NextParameters=  load([ParamFileBaseName num2str(UpdateBlockNum)]);
                                Parameters.Phit=NextParameters.Parameters.Phit;
                                Parameters.BlockTime=NextParameters.Parameters.BlockTime;
                                Parameters.Mag=NextParameters.Parameters.Mag;
                                Parameters.std2power=NextParameters.Parameters.std2power;
                                Parameters.meanpower=NextParameters.Parameters.meanpower;
                                Parameters.estNpower=NextParameters.Parameters.estNpower;
                                Parameters.Drift=NextParameters.Parameters.Drift;
                                Parameters.Ca1=Ca1List(iii);
                                Parameters.Ca2=Ca2List(jjj);
                                Parameters.Amax=AmaxList(kkk);
                                Parameters.Cb=CbList(lll);
                                %Calc New Weights
                                %===============================================================
                                %=================================
                                [x iBest]=sort(Parameters.Phit,'descend');
                                if x(1)==x(2)
                                    if Parameters.BlockTime(iBest(1))<Parameters.BlockTime(iBest(2))
                                        iBest=iBest(1);
                                    else
                                        iBest=iBest(2);
                                    end
                                else
                                    iBest=iBest(1);
                                end

                                iBlockOld=iUpdateBlock;
                                %UpdateBlockNum=UpdateBlockNum+1;

                                iUpdateBlock=mod(UpdateBlockNum+Parameters.NumBlocksHeld-1,Parameters.NumBlocksHeld)+1;

                                phitmax=Parameters.Phit(iBest);
                                if((Parameters.Phit(iBest)+Parameters.Phit(iBlockOld))<0.01)
                                    phitmax=0.01;
                                end
                                partold=phitmax/(phitmax+Parameters.Phit(iBlockOld)+0.01);
                                partold=1-((1-partold)*(1-(0.97*(phitmax-Parameters.Phit(iBlockOld)))));

                                if(partold>0.98)
                                    partold=0.98;
                                end


                                meanphit=mean(Parameters.Phit);
                                Ao   = Parameters.Amax - (meanphit* Parameters.Ca2* Parameters.Amax); % Alpha
                                %scalenZ[i]=errnZ[i]/dMCnz[i];==AbsMeanErrorP/MeanAbsErrorP
                                MeanErrorP=dWp./(UpdateTallyP*ones(1,VR.num_dim));%dCpx[i]/(float) countdC===DWxpi(S)  = Ek[Wxpi(k)NRi(k) –(Tx(k)-Cx(k))]
                                MeanErrorN=dWn./(UpdateTallyN*ones(1,VR.num_dim));
                                AbsMeanErrorP=abs(MeanErrorP);% errp    %total num decode channels x num dim
                                AbsMeanErrorN=abs(MeanErrorN);%total num decode channels x num dim

                                MeanAbsErrorP=dAbsErrorP./(UpdateTallyP*ones(1,VR.num_dim));%dMCp
                                MeanAbsErrorN=dAbsErrorN./(UpdateTallyN*ones(1,VR.num_dim));
                                MeanAbsErrorP(find(MeanAbsErrorP< .0001))=.0001;
                                MeanAbsErrorN(find(MeanAbsErrorN< .0001))=.0001;

                                EMp=AbsMeanErrorP;%errp
                                EMn=AbsMeanErrorN;
                                ECp=AbsMeanErrorP./MeanAbsErrorP;
                                ECn=AbsMeanErrorN./MeanAbsErrorN; %scalen

                                NEMp=(EMp-ones(size(EMp(:,1)))*median(EMp))./(2*ones(size(EMp(:,1)))*mean( abs((EMp-ones(size(EMp(:,1)))*median(EMp)))));
                                NEMp(find(NEMp>1))=1;
                                NEMp(find(NEMp<-1))=-1;
                                NEMp(find(isnan(NEMp)==1))=eps(0);

                                NEMn=(EMn-ones(size(EMn(:,1)))*median(EMn))./(2*ones(size(EMn(:,1)))*mean( abs((EMn-ones(size(EMn(:,1)))*median(EMn)))));
                                NEMn(find(NEMn>1))=1;
                                NEMn(find(NEMn<-1))=-1;
                                NEMn(find(isnan(NEMn)==1))=eps(0);

                                NECp=(ECp-ones(size(ECp(:,1)))*median(ECp))./(2*ones(size(ECp(:,1)))*mean( abs((ECp-ones(size(ECp(:,1)))*median(ECp)))));
                                NECp(find(NECp>1))=1;
                                NECp(find(NECp<-1))=-1;
                                NECp(find(isnan(NECp)==1))=eps(0);

                                NECn=(ECn-ones(size(ECn(:,1)))*median(ECn))./(2*ones(size(ECn(:,1)))*mean( abs((ECn-ones(size(ECn(:,1)))*median(ECn)))));
                                NECn(find(NECn>1))=1;
                                NECn(find(NECn<-1))=-1;
                                NECn(find(isnan(NECn)==1))=eps(0);

                                Ap = Ao*( 1 + Parameters.Ca1*(NEMp + NECp) ) ;%(1.0+(Dev_Adjust*(errpX[i]+scalepX[i])))*Alpha*
                                An = Ao*( 1 + Parameters.Ca1*(NEMn + NECn) ) ;

                                Bp=1+Parameters.Cb*(1-meanphit)*(NECp-NEMp);%(1.0+(Full_Adjust*(scalepY[i]-errpY[i])*(1.0f-meanphit)))===1 + CBBo(N[ECxpi(S)]- N[EMxpi(S)])  where Bo= 1 - En[Phit(n)]   (n: S-0, S-1,...,S-N+1)
                                Bn=1+Parameters.Cb*(1-meanphit)*(NECn-NEMn);

                                %Cp[i][0][iset]=(((Cp[i][0][isetold]-((1.0+(Dev_Adjust*(errpX[i]+scalepX[i])))*Alpha*dCpx[i]/(float) countdC))*(1.0f-partold))+(partold*Cp[i][0][iPhitmax]))*(1.0+(Full_Adjust*(scalepX[i]-errpX[i])*(1.0f-meanphit)));
                                Parameters.Wp(:,:,iUpdateBlock)=Bp.*(((1-partold)*(Parameters.Wp(:,:,iBlockOld)-Ap.*MeanErrorP)) + (partold*Parameters.Wp(:,:,iBest)));%Cp[i][0][iset]=(((Cp[i][0][isetold]-((1.0+(Dev_Adjust*(errpX[i]+scalepX[i])))*Alpha*dCpx[i]/(float) countdC))*(1.0f-partold))+(partold*Cp[i][0][iPhitmax]))*(1.0+(Full_Adjust*(scalepX[i]-errpX[i])*(1.0f-meanphit)));
                                Parameters.Wn(:,:,iUpdateBlock)=Bn.*(((1-partold)*(Parameters.Wn(:,:,iBlockOld)-An.*MeanErrorN)) + (partold*Parameters.Wn(:,:,iBest)));

                                Parameters.Drift=zeros(1,VR.num_dim);
                                %Parameters.estNpower=dEstNpower/UpdateTally;
                                for i=1:decode.num_totalchan

                                    for j=1:VR.num_dim
                                        Parameters.Drift(1,j)=Parameters.Drift(1,j)+Parameters.Wp(i,j,iUpdateBlock)*0.5*Parameters.estNpower(i) - Parameters.Wn(i,j,iUpdateBlock)*0.5*Parameters.estNpower(i);
                                    end
                                end

                                Parameters.Mag(iUpdateBlock,:)=dMag/UpdateTally*(1-partold) + partold*Parameters.Mag(iBest,:);
                                %Parameters.RMag(iUpdateBlock,:)=dRMag/UpdateTally*(1-partold) + partold*Parameters.RMag(iBest,:);

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
                            end%if oldparameters need updating
                            %=========================================================================
                            %================
                            %now calc a new dxdy
                            if VR.BC_flag
                                for i=1:VR.num_dim
                                    PV(1,i)=(data.normalized>0).*Parameters.Wp(:,i,iUpdateBlock)'*data.normalized' +(data.normalized<0).*Parameters.Wn(:,i,iUpdateBlock)'*data.normalized';
                                end
                                V=((PV-Parameters.Drift)*VR.Vscale)./Parameters.Mag(iUpdateBlock,:);%this normalizes the magnitudes along the X, Y & Z axes



                                UpdateTally=UpdateTally+1;
                                UpdateTallyP=UpdateTallyP+(data.normalized>0)';
                                UpdateTallyN=UpdateTallyN+(data.normalized<0)';
                                Dist=VR.target_position-VR.cursor_position;
                                dEstNpower=dEstNpower+abs(data.normalized');
                                dMag=dMag + abs(PV-Parameters.Drift);
                                for i=1:VR.num_dim
                                    dWp(:,i)=dWp(:,i)+(data.normalized>0)'.*((Parameters.Wp(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wp(:,1,1)))));
                                    dWn(:,i)=dWn(:,i)-(data.normalized<0)'.*((Parameters.Wn(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wn(:,1,1)))));
                                    dAbsErrorP(:,i)=dAbsErrorP(:,i) +abs((data.normalized>0)'.*((Parameters.Wp(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wp(:,1,1))))));
                                    dAbsErrorN(:,i)=dAbsErrorN(:,i) +abs((data.normalized<0)'.*((Parameters.Wn(:,i,iUpdateBlock).*data.normalized')-(Dist(i)*ones(size(Parameters.Wn(:,1,1))))));
                                end


                                %Get angle between Vel and what is needed
                                Velmag=sqrt(V*V');
                                Vunit=V/Velmag;
                                Distmag=sqrt(Dist*Dist');
                                NeededUnit=Dist/Distmag;
                                erroranglesum=erroranglesum+abs(acos(NeededUnit*Vunit'));
                                TallyErrorAngle=TallyErrorAngle+1;
                            end % if VR.BC_flag
                        end%if line~=-1
                    end%while line~=-1
                
                     MeanErrorAngle(UpdateBlockNum,iii, jjj, kkk,lll)= erroranglesum/TallyErrorAngle;
                     GrandMeanErrorAngle(iii, jjj, kkk,lll)= mean(MeanErrorAngle(:,iii, jjj, kkk,lll));
                               disp(num2str([iii jjj kkk lll]));
                    %should be the end of it all.....
                    save([ParamFileBaseName 'Analyzed'],'MeanErrorAngle','GrandMeanErrorAngle', 'iii', 'jjj', 'kkk', 'lll', 'Ca1List', 'Ca2List', 'AmaxList', 'CbList');
                    fclose(fCursIn);
                  
                    CycleCount=CycleCount+1;
                end% if you can open cursor file
                
            end%lll
            toc
            disp(['Analysis is ' num2str(CycleCount/NCycles*100) '% complete']);
        end%kkk
    end%jjj
end%iii
VGrandMeanErrorAngle=reshape(GrandMeanErrorAngle,[],625);
M=min(VGrandMeanErrorAngle);
for iii=length(Ca1List):-1:1
    Ca1=Ca1List(iii);
    for jjj=length(Ca2List):-1:1
        Ca2=Ca2List(jjj);
        for kkk=length(AmaxList):-1:1
            Amax=AmaxList(kkk);
            for lll=length(CbList):-1:1
                Cb=CbList(lll);
                if(M==GrandMeanErrorAngle(iii, jjj, kkk,lll))
                    BestCa1=Ca1List(iii)
                    BestCa2=Ca2List(jjj)
                    BestAmax=AmaxList(kkk)
                    BestCb=CbList(lll)
                  save([ParamFileBaseName 'Analyzed'],'MeanErrorAngle','GrandMeanErrorAngle', 'iii', 'jjj', 'kkk', 'lll', 'Ca1List', 'Ca2List', 'AmaxList', 'CbList','BestCa1','BestCa2','BestAmax','BestCb');
                end
            end%lll

        end%kkk
    end%jjj
end%iii

