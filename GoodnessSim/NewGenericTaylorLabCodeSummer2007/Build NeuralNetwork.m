%FixCorrelations9-19-05 adjusts correlations based on what has been
%correlated up to this point. This closes and loads cursor file, deduces
%correlations from cursor data
%FixCorrelations 11/9/05 fix correlations 4_1b runs the linear correlation
%correction and the new gental warping function (version 4_1 was used once
%with the original NN function that was not appropriate
% ===============
% OutName=['C:\Data\Test\DMT110705\DMT11070502'];
% VR.targets=[1 1;-1 1; 1 -1; -1 -1]
% VR.num_dim=2
% VR.num_targets=4
% R=[cos(pi/4) sin(pi/4); -sin(pi/4) cos(pi/4)];
% 
%  ===================================
addpath(['C:\Taylor\Matlab Code\AnalysisCode']);
NUM_INTO_TRIAL=20
disp('in fix corr4_1')
[message]=fclose(fpCO);
 [fpCO message]=fopen([OutName '.cen_out'],'rt');
    if fpCO==-1
        disp(['could not open' OutName '.cen_out']);
        keyboard
    end
    line=fgetl(fpCO);
    while(line~=-1)
        line=fgetl(fpCO);
        if ~isempty(findstr(line,'Parameters'))==1 %this section counts the number of processed inputs used
            matches=[]
            NumInputs=-1;
            WeightMat=[];
            TargetRadius=[];
            Performance=[];
            Magnitude=[];
            while isempty(matches)
                line=fgetl(fpCO);
                matches=findstr(line,'999999999')
                if isempty(matches)
                    WeightMat=[WeightMat;str2num(line)];
                else
                    linehold=str2num(line);
                    TargetRadius=[TargetRadius linehold(length(linehold)-4)];
                    Performance=[Performance linehold(length(linehold))];
                    Magnitude=[Magnitude ;linehold(2+VR.num_dim : 1+2*VR.num_dim) ];

                end
                NumInputs=NumInputs+1;
            end
            WSet(1).wmt=WeightMat(:,4:4+2*VR.num_dim-1).*(WeightMat(:,size(WeightMat,2))*ones(1,2*VR.num_dim));
            matches=[];
            WeightBlockCount=1;
            WeightMat=[];
            line=fgetl(fpCO);
            while (line~=-1)
                matches=findstr(line,'999999999')
                if isempty(matches)
                    matches=findstr(line,'Comments')
                    if isempty(matches)
                        WeightMat=[WeightMat;str2num(line)];
                    end
                else
                    linehold=str2num(line);
                    TargetRadius=[TargetRadius linehold(length(linehold)-4)];
                    Performance=[Performance linehold(length(linehold))];
                    Magnitude=[Magnitude ;linehold(2+VR.num_dim : 1+2*VR.num_dim) ];
                    WeightBlockCount=WeightBlockCount+1;
                    WSet(WeightBlockCount).wmt=WeightMat(:,1:2*VR.num_dim).*(WeightMat(:,size(WeightMat,2))*ones(1,2*VR.num_dim));
                    WeightMat=[];
                end
                line=fgetl(fpCO);
            end%while not end of file
        end

    end%while not end of file
    magmatrix=[]
    for i=1:VR.num_dim
        magmatrix=[magmatrix Magnitude(:,i) Magnitude(:,i)];
    end

    plotweight=[]
    for i=1:WeightBlockCount-1
        x=reshape(abs((WSet(i+1).wmt./(ones(NumInputs,1)*magmatrix(i+1,:)))-(WSet(i).wmt./(ones(NumInputs,1)*magmatrix(i,:)))),1,[]);
        plotweight=[ plotweight; x];
    end
    subplot(3,1,3)
    plot(plotweight);
    subplot(3,1,2)
    plot(Performance);
    subplot(3,1,1)
    plot(TargetRadius);
    display('Define block range to use in correlation analysis or weight pruning or weight fixing: e.g. blockrange=[2:7 9:12]. Then type return')
    keyboard
    if max(blockrange)>WeightBlockCount
        display(['max range is ' num2str(WeightBlockCount) ' Enter new range, Then type return']);
        keyboard
    end
     [message]=fclose(fpCO);
            [fpCO message]=fopen([OutName '.cen_out'],'at');% This reopens the cen_out file in append mode
                if fpCO==-1
                    disp(['could not open' OutName '.cen_out']);
                    KeepRunningFlag=0;
                end
                
     [message]=fclose(fpCurs);
     dat=load([OutName '.cursor']);
     sizedat=size(dat,1);
%      n=floor(event.BlockNum/adaptive.minblocks_in_test);
%      chunks=floor(sizedat/n);
%      startdat=(chunks*(n-1))+ round(0.2*chunks);
%      dat=dat(startdat:size(dat,1),:);%This just looks at the last 2/3rd of the data assuming initial weights are garbage
    goodi=zeros(size(dat,1),1);

    BC=dat(:,8);
    invec=[]
    targvec=[]
    targpositions=[]
    istarts= find(diff(BC)==1)+NUM_INTO_TRIAL;
    for i=1:length(istarts)
        if(~isempty(find(dat(istarts(i),5)==blockrange)))
            invec=[ invec; dat(istarts(i), 10:11)];
            targvec=[targvec;dat(istarts(i), 6)];
            targpositions=[targpositions; dat(istarts(i),13:14)];
        end
    end
    
    %eliminates ones that are way off >pi/2
    Maginvec=sqrt((invec.*invec)*[1;1]);
    uinvec=invec./(Maginvec*[1 1]);
    Magtargpos=sqrt((targpositions.*targpositions)*[1;1]);
    utargpos=targpositions./(Magtargpos*[1 1]);
    checkangel=acos((utargpos.*uinvec)*[1; 1])
    newgoodi=find(checkangel<(pi/2.5));

    uinvec=uinvec(newgoodi,:);
    targvec=targvec(newgoodi,:);
    figure
    colors=['-k';'-c';'-r';'-g']
    for i=1:4
        hold on
        index=find(targvec==i)
        for j=1:length(index)
            plot([0 uinvec(index(j),1)], [0 uinvec(index(j),2)], colors(i,:));
            hold on
        end
    end
        
    [NNInputs,NNOutputs]=GentleWarping(uinvec,targvec,VR.targets)
    
   
    
      adaptivehold=adaptive;
      adaptivehold.net=fNetTrajectCorrector(NNInputs,NNOutputs)
      save([OutName 'test111005Stuff_For_NN'],'adaptivehold','NNInputs','NNOutputs');

   

               %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ++++++++++++++++++++++++++++++++++
               %++++++++++++++++++++++++++++++++++++
 goodi=zeros(size(dat,1),1);

	for i=1:length(blockrange)
        goodi(find(dat(:,5)==blockrange(i)))=1;%this finds blocks whos update num match the block range
    end
    
      goodi=find(goodi.*dat(:,8)>0.5);% This picks out indexes for the data created under brain control in the desired blocks
       Targetnum=dat(goodi,6);% and the associated target
     
     dxy=dat(goodi,16:17);% this gets all dx and dy values during brain control for the last 2/3rd of the set
    
       dxy=abs((R*dxy')');%This rotates 45degrees and then takes the absolute value
       xy=[0 0]
       for i=1:VR.num_targets
         xy=xy + mean(dxy(find(Targetnum==i),:));%This gets the mean of those rotated values by target and then calculates the mean across targets
       end
       xy=xy/VR.num_targets;
       adaptive.RMag(:,1)=(xy*[.5 ;.5])/xy(1);%These provide the normalization correction factor for X & Y ie the average x and y magnitudes/(mean x magnitude or the mean y magnitude). This should keep overall scaling the same
       adaptive.RMag(:,2)=(xy*[.5 ;.5])/xy(2);
       
           clear dat 
           clear dxy
           clear Targetnum
           clear goodi
clear NNInputs
clear NNOutputs
clear adaptivehold
clear Magtargvec
clear utargvec
clear Magtargpos
clear utargpos
clear checkangel
clear  newgoodi

        [fpCurs message]=fopen([OutName '.cursor'],'at');% This reopens the cursor file in append mode
                if fpCurs==-1
                    disp(['could not open' OutName '.cursor']);
                    KeepRunningFlag=0;
                end
                
           
                