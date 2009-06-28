close all
clear all
Ca1List=0.05:.1:0.5;
Ca2List=0.05:.2:1;
AmaxList=0.05:.1:0.5;
CbList=0.05:.1:0.5;

xEndingTargRad=ones(10,length(Ca1List) ,length(Ca2List),length(AmaxList),length(CbList))*1;
xEndingTargRad(:,[1 3 4],:,:,:)=0;
 load('C:\data\sim\HoldSimVars')
  load('C:\data\sim\UberEndingTargRad')
 xEndingTargRad(find(EndingTargRad>0))=EndingTargRad(find(EndingTargRad>0));
 EndingTargRad= UberEndingTargRad;
  EndingTargRad= UberEndingTargRad;
for iii=1:length(Ca1List)
    for jjj=1:length(Ca2List)
        for kkk=1:length(AmaxList)
            for lll=1:length(CbList)
                for nrepeats=1:10
                    if EndingTargRad(nrepeats,iii ,jjj,kkk,lll)==0 || EndingTargRad(nrepeats,iii ,jjj,kkk,lll)==1
                        Parameters.Ca1=Ca1List(iii);
                        Parameters.Ca2=Ca2List(jjj);
                        Parameters.Amax=AmaxList(kkk);
                        Parameters.Cb=CbList(lll);
                        %Rerun simulations
                        ConfigureExperimentForFakeDataSimulationLooped
                        EndingTargRad(nrepeats,iii ,jjj,kkk,lll)=VR.TargRad;
                        EndingPhits(nrepeats,iii ,jjj,kkk,lll)=mean(Parameters.Phit);

                        save('C:\data\sim\HoldSimVars2','Ca1List', 'Ca2List', 'AmaxList', 'CbList','iii' ,'jjj','kkk','lll','nrepeats', 'EndingTargRad', 'EndingPhits')
                        clear Parameters
                        GClose
                        clear all
                        load('C:\data\sim\HoldSimVars2')
                        disp(num2str([iii jjj kkk lll nrepeats]));
                        pause(1);
                    end
                end%nrepeats

            end%lll
        end%kkk
    end%jjj
end%iii