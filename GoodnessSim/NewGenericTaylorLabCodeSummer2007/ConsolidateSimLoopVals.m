clear all
load('C:\data\sim\UberEndingTargRadV2')
 
load('C:\data\sim\HoldSimVars33')%put your latest file name here 
EndingTargRad(find(EndingTargRad==1))=0;
for iii=1:length(Ca1List)
    for jjj=1:length(Ca2List)
        for kkk=1:length(AmaxList)
            for lll=1:length(CbList)
                for nrepeats=1:10
                    if EndingTargRad(nrepeats,iii ,jjj,kkk,lll)>0 && EndingTargRad(nrepeats,iii ,jjj,kkk,lll)<1
                        if UberEndingTargRad(nrepeats,iii ,jjj,kkk,lll)==0 
                                UberEndingTargRad(nrepeats,iii ,jjj,kkk,lll)=EndingTargRad(nrepeats,iii ,jjj,kkk,lll);
                        else
                            if nrepeats<=5
                                if UberEndingTargRad(nrepeats+5,iii ,jjj,kkk,lll)==0 
                                UberEndingTargRad(nrepeats+5,iii ,jjj,kkk,lll)=EndingTargRad(nrepeats,iii ,jjj,kkk,lll);
                                end
                            else
                                if UberEndingTargRad(nrepeats-5,iii ,jjj,kkk,lll)==0 
                                UberEndingTargRad(nrepeats-5,iii ,jjj,kkk,lll)=EndingTargRad(nrepeats,iii ,jjj,kkk,lll);
                                end
                            end
                        end
                    end

                end%nrepeats

            end%lll
        end%kkk
    end%jjj
end%iii

for iii=1:length(Ca1List)
    for jjj=1:length(Ca2List)
        for kkk=1:length(AmaxList)
            for lll=1:length(CbList)
                zerolist=find(UberEndingTargRad(:,iii ,jjj,kkk,lll)==0);
                if length(zerolist)==5
                    nonzerolist=find(UberEndingTargRad(:,iii ,jjj,kkk,lll)~=0);
                    UberEndingTargRad(zerolist,iii ,jjj,kkk,lll)=UberEndingTargRad(nonzerolist,iii ,jjj,kkk,lll);
                end
            end%lll
        end%kkk
    end%jjj
end%iii
save('C:\data\sim\UberEndingTargRad','UberEndingTargRad')
% Restart simulations but replace current EndingTargRad with values in 
% UberEndingTargRad
 
