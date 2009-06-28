%Percentgood from EndingTArgRad
MeanEndingTargRad=mean(EndingTargRad,1);
MeanAscendingEndingTargRad=sort(reshape(MeanEndingTargRad,[],5^4))'

plot(MeanAscendingEndingTargRad)
Ca1List=0.05:.1:0.5;
Ca2List=0.05:.2:1;
AmaxList=0.05:.1:0.5;
CbList=0.05:.1:0.5;
totalnum=length(MeanAscendingEndingTargRad)
PercentGood=zeros(1,5,5,5,5);

for iii=1:length(Ca1List)
    for jjj=1:length(Ca2List)
        for kkk=1:length(AmaxList)
            for lll=1:length(CbList)
                x=find(MeanAscendingEndingTargRad==MeanEndingTargRad(1,iii,jjj,kkk,lll));

                PercentGood(1,iii,jjj,kkk,lll)= (1-x(1)/totalnum)*100;
            end%lll
        end%kkk
    end%jjj
end%iii
UberEndingTargRad=EndingTargRad

save('C:\data\sim\UberEndingTargRadFinal','UberEndingTargRad','MeanAscendingEndingTargRad','PercentGood', 'Ca1List', 'Ca2List', 'AmaxList', 'CbList')