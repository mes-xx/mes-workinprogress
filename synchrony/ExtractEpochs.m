function [Epochs,Cue,Stacked_Epochs,Stacked_Cue] =ExtractEpochs(P,L,T,C,fsEEG,fsCue,Duration)

% Parameters
fseeg=fsEEG;fscue=fsCue;
Trig_T=T;Trig_Cue=C;
ch=size(P,2);


% Function

dtr=taskduration_v1(L);
T=floor([Duration(2):1/fseeg:Duration(3)]*fseeg);
Trig_T=floor(Trig_T*fseeg);
Epochs=zeros(length(Trig_T),length(T),ch); Cue=zeros(length(Trig_T),length(T));
k=1; Stacked_Cue=[];Stacked_Epochs=[];
for i=1:length(Trig_T)
    id=dtr(Trig_Cue(i,2),1)+Trig_T(i)+T;

    if max(id)<size(P,1)
        Epochs(k,:,:)=P(id,1:ch); % Epochs defined around a triggering event (Cue,EMG, or a sensor data).
        Cue(k,:)=L(id);% Corresponding cue.
        Stacked_Epochs=[Stacked_Epochs,(P(id,1:ch)')];
        Stacked_Cue=[Stacked_Cue;L(id,:)];
        k=k+1;
    end
    
end


% Output
clear Trig_* T L P dtr ch;
