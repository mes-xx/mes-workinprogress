% function P1 = CalcPower(X,Y,Extract)
% Calculates power using fft and averages together frequency bands as
% specified in the stucture Extract in the field fr_avg. If fr_Avg=1, it
% returns the power spectrum at all frequency bands.
% X=data
% Y=cue information
% Extract.W=window of data to be used for calculating power
% Extract.Shift= Shift the window by
% Extract.idx=index of optimal channels and frequency bands. if empty, will
% return all frequency bands.

function [P1,L,Extract] = CalcPower(X,Y,Extract)

% Parameters
W=floor(Extract.W*Extract.fseeg);
Shift=floor(Extract.Shift*Extract.fseeg);
mo=Extract.mo;

for i=1:size(Extract.filter_bp,1)
    idx=(Extract.fr>=Extract.filter_bp(i,1) & Extract.fr<=Extract.filter_bp(i,2));
end

if isempty(Extract.idx)
    Extract.idx=idx;clear idx;
end

% function
switch Extract.feature
    case 'AR'
%        [temp,Extract.fr]=arspec(X(1,1:700),17,100);clear temp;

        AIC=zeros(size(X,1),length(mo));
        for k=1:size(X,1)
            for i=1:length(mo)
                keyboard %%%DEBUG
                [a,e]=arburg(X(k,1:W),mo(i)); clear a;
                AIC(k,i)=W*log10(e)+(2*mo(i));
            end
        end
        [temp,optmo]=min(AIC'); clear e m temp

        % Computation of power using BURG's AR method
        P1=zeros(6000,floor(sum(Extract.idx)/Extract.fr_avg)*size(X,1));n=1;r=1;
        win=hamming(W);WIN=ones(size(X,1),1)*win';clear win;id=1;
        L=zeros(6000,size(Y,2));

        while(n<=size(X,2)-W && id<=length(Y))
            for i = 1:size(X,1),
                temp1(i,:)=pburg(X(i,n:n+W-1),optmo(i),W,Extract.fseeg);
%                 [temp1(i,:)]=arspec(X(i,n:n+W-1),optmo(i),100);

            end
            temp2(:,:)=temp1(:,Extract.idx);

            if Extract.fr_avg>1
                k=1;
                for j=1:Extract.fr_avg:size(temp2,2)-Extract.fr_avg+1
                    temp3(:,k)=mean(temp2(:,j:j+Extract.fr_avg-1),2);k=k+1;
                end

            else
                temp3=temp2;
            end

            for i=1:size(temp3,1)
                temp3(i,:)=temp3(i,:)./sum(temp3(i,:));
            end

            temp4=reshape(temp3',1,[]);

            if ~isempty (Extract.idx)
                P1(r,:)=10*log10(temp4); clear temp*
            else
                P1(r,:)=10*log10(temp4); clear temp*;
            end

            id=floor(((n+W-1)/Extract.fseeg)*Extract.fslabel);L(r,:)=Y(id,:);
            n=n+Shift;r=r+1; id=floor(((n+W-1)/Extract.fseeg)*Extract.fslabel);        
        end

    case 'FFT'
        P1=zeros(6000,floor(sum(Extract.idx)/Extract.fr_avg)*size(X,1));n=1;r=1;
        win=hamming(W);WIN=ones(size(X,1),1)*win';clear win;id=1;
        L=zeros(6000,size(Y,2));
        while(n<=size(X,2)-W) && id<=length(Y)
            temp1=(fft((WIN.*X(:,n:n+W-1))')./length(WIN))';
            temp1=temp1.*conj(temp1);

            temp2(:,:)=temp1(:,Extract.idx);

            if Extract.fr_avg>1
                k=1;
                for j=1:Extract.fr_avg:size(temp2,2)-Extract.fr_avg+1
                    temp3(:,k)=mean(temp2(:,j:j+Extract.fr_avg-1),2);k=k+1;
                end
                
            else
                temp3=temp2;
            end

            for i=1:size(temp3,1)
                temp3(i,:)=temp3(i,:)./sum(temp3(i,:));
            end

            temp4=reshape(temp3',1,[]);

            if ~isempty (Extract.idx)
                P1(r,:)=log(temp4); clear temp*
            else
                P1(r,:)=log(temp4); clear temp*;
            end

%             id=floor(((n+W-1)/Extract.fseeg)*Extract.fslabel);
%             L(r,:)=Y(id,:);
            n=n+Shift;r=r+1; id=floor(((n+W-1)/Extract.fseeg)*Extract.fslabel);
        end
    case 'BP'
        P1=zeros(6000,size(X,1));n=1;r=1;L=zeros(6000,size(Y,2));

        while(n<=size(X,2)-W)
            temp1=var(X(:,n:n+W-1)');
            temp1=10*log10(temp1./sum(temp1));
            P1(r,:)=temp1; clear temp*;
            id=floor(((n+W-1)/Extract.fseeg)*Extract.fslabel);L(r,1)=Y(id);
            n=n+Shift;r=r+1;
        end
end

if r<6000
    P1(r:6000,:)=[];L(r:6000,:)=[];Extract.fseeg=Extract.fseeg/Shift;Extract.fslabel=Extract.fseeg;
end
