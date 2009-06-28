%This file reads in cursor file from balistic test (VRMIX1.21) and plots the sets and Hits
%Version 3 3-12-08 throws exception when problems found ~mes
%Version 2 8-26-01 looks at histograms of abs(diff HC Curs and HCinterp) to pick optimal offsets
%6-17-02 replotting a good example with black hit dots
clear;

p1=[1:4];
p2=[5:8];
%v1=[2.0 0.0 1.0];
%v2=[2.0 0.0 1.0];
v1=[1.0 0.0 0.0];
v2=[1.0 0.0 0.0];
ccode=['r-';'g-';'c-';'b-']
ccodes=['k.';'k.';'k.';'k.']
fignum=100;
figsize=50;
targ=[-1 -1 1;-1 1 1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 -1 ; 1 1 1; 1 -1 1 ];
center=[17.3  -106.8 -1775.5];
center2=[106.8 17.3 -1775.5]
%116.85	-60.23	-1789.85
FigureSize    =    50;
TargetRadius   =   35;
CursorRadius   =   10;
indist=45;
namelistM1=[   'M0221R'; 'M0222R'; 'M0227R'; 'M0306R']
%[  'M0108R'; 'M0118R'; 'M0119R'; 'M0122R'; 'M0126R'; 'M0131R';
%'M0205R';'M0215R';
namelist=[namelistM1]
for day=1:size(namelist,1)%:20
    Shiftlist=[];
    inamelist=day;
    name=namelist(day,:);
    fignum=fignum+1;
    filelist=[];
    totalsets=0;
    for i=1:5
        path=['F:\school\research\data\ballistic\' name(1,1:5) '\' name '0' int2str(i) '.cursor' ]
        if(exist(path)==2)
            filelist=[filelist;i];
        end
    end
    if(isempty(filelist))
        error('No Cursor files')
    else
        disp([namelist(inamelist,:) ' has cursor files ' int2str(filelist')]);
    end
    for file2=1:length(filelist)
        file=filelist(file2);
        %dat=load(['\\Basal\big_drive\VRData\Mojo\' name(1,1:5) '\' name '0' num2str(file) '.cursor']);
        dat=load(['F:\school\research\data\ballistic\' name(1,1:5) '\' name '0' num2str(file) '.cursor']);
        
        [r c]=size(dat);
        r=r-2;
        
        getstart=find(abs(diff(dat(1:1000,c-7)))>(200));
        if(isempty(getstart))
            start=1
        else
            start=getstart(1)+1;
        end
        
        BC=dat(start:r,c-1);
        Tnum=dat(start:r,c);
        if(~isempty(find(Tnum<.99)))
            error('Targets are less than 1');
        end
        PartBC=find(dat(start:r,c-3)<.999);
        if(~isempty(PartBC))
            figure(6666)
            plot(dat(start:r,c-3));
            title(['part BC ' cenpath]);
            
            keyboard
        end
        PV=dat(start:r,[(c-6):(c-4)]);
        Curs=dat(start:r,[(c-11) (c-9) (c-7)]);
        Fig=dat(start:r,[(c-12) (c-10) (c-8)]);
        figure(1);
        plot(Curs(1:200,:));
        disp('does start look okay?')
        %keyboard
        VScale=dat(start:r,[(c-15) (c-14) (c-13)]);
        InSphere=dat(start:r,(c-16));
        TS=dat(start:r,(c-17));
        clear dat;
        dat=load(['F:\school\research\data\ballistic\' name(1,1:5) '\' name '.0' num2str(file) '.ascii']);
        HCPos=dat(:,1:3);
        HCPos=HCPos-ones(length(HCPos),1)*center2;
        HCPos(find(abs(HCPos(:,1))>500),:)=NaN;
        
        TSms=(TS-ones(size(TS))*TS(1))/40;
        Curs(find(abs(Curs(:,1))>500),:)=NaN;
        HCCurs=Curs;
        HCCurs(find(BC>0.9),:)=NaN;
        Posms=1:size(dat,1);
        Posms=Posms*10-10;
        
        zeromag1=[];
        shift1=[];
        for i=-50:5:50
            HCposinterp=interp1(Posms,HCPos,TSms+i);
            
            if(size(HCposinterp)==size(HCCurs))
                er=abs([HCposinterp(:,1);HCposinterp(:,2);HCposinterp(:,3);]-[HCCurs(:,1);HCCurs(:,2);HCCurs(:,3)]);
                res=HISTC(er,[0  2  4 6 8 10]);
                res=res/sum(res);
                zeromag1=[zeromag1;res(1)];
                shift1=[shift1;i];
            else
                error(  'HCposinterp is diff length than  HCCurs'); 
            end
            
            
        end
        res=0;
        [Y,I] = max(zeromag1);
        if(Y>.9)
            shift=shift1(I);
        else
            
            while(res(1)<.77)
                HCposinterp=interp1(Posms,HCPos,TSms+i);
                if(size(HCposinterp)==size(HCCurs))
                    er=abs([HCposinterp(:,1);HCposinterp(:,2);HCposinterp(:,3);]-[HCCurs(:,1);HCCurs(:,2);HCCurs(:,3)]);
                    res=HISTC(er,[0  2  4 6 8 10]);
                    res=res/sum(res);
                else
                    error(  'HCposinterp is diff length than  HCCurs'); 
                end
                [i res(1)]
                i=i+30
                
            end
            zeromag1=[];
            shift1=[];
            for q=i-30:5:i+200
                
                HCposinterp=interp1(Posms,HCPos,TSms+q);
                if(size(HCposinterp)==size(HCCurs))
                    er=abs([HCposinterp(:,1);HCposinterp(:,2);HCposinterp(:,3);]-[HCCurs(:,1);HCCurs(:,2);HCCurs(:,3)]);
                    res=HISTC(er,[0  2  4 6 8 10]);
                    res=res/sum(res);
                    zeromag1=[zeromag1;res(1)];
                    shift1=[shift1;q];
                else
                    error(  'HCposinterp is diff length than  HCCurs'); 
                end
            end
            [Y,I] = max(zeromag1);
            if(Y>.9)
                shift=shift1(I);
            else
                error('never found good shift');
                keyboard
            end
            HCposinterp=interp1(Posms,HCPos,TSms+shift);
            figure(2)
            plot(HCposinterp(:,1),'r-')
            hold on
            plot(HCCurs(:,1),'r:')
            hold on
            plot(HCposinterp(:,2),'g-')
            hold on
            plot(HCCurs(:,2),'g:')
            hold on
            plot(HCposinterp(:,3),'b-')
            hold on
            plot(HCCurs(:,3),'b:')
            axis([100 500 -200 200]);
            title(['shift=' num2str(shift)]);
            disp('is this shift okay?')
            %keyboard
        end
        %close all
        File(file).shift=shift
        HCposinterp=interp1(Posms,HCPos,TSms+shift);
        
        
        targfull=ones(length(BC),3)*NaN;
        goodi=find((abs(Fig(:,2))>10)&(abs(Fig(:,2))<200))
        targfull(goodi,:)=sign(Fig(goodi,:));
        
        DistHintotarg=DistanceMag(targfull*figsize,HCposinterp);
        
        InSphereHin=zeros(size(BC));
        InSphereHin(find(DistHintotarg<indist))=1;
        
        bci=find((abs(Fig(:,2))<100)&(abs(Fig(:,2))>1)&(BC>0.9));
        startsbc=find(diff(bci)>1)+1;
        startsbc=[1 ;startsbc];
        if(BC(length(BC))==1)%If last BC trial cut off in the middle
            %leave as is and last one will be ignored
        else
            startsbc=[startsbc;length(bci)+1];
        end
        %plot(Fig(bci,:));
        %title('check for weird fig vals BC');
        %pause
        
        hci=find((abs(Fig(:,2))<100)&(abs(Fig(:,2))>1)&(BC<0.1));
        startshc=find(diff(hci)>1)+1;
        startshc=[1 ;startshc];
        if(hci(length(hci))==r)%If last HC trial cuts off in the middle
            %leave as is and last one will be ignored
        else
            startshc=[startshc;length(hci)+1];
        end
        %plot(Fig(hci,:));
        %title('check for weird fig vals HC');
        %pause
        
        
        setlist=[];
        set=1;
        for i=1:size(startsbc,1)-1
            if(i>1)
                x=find(diff(Fig(bci(startsbc(i-1)):bci(startsbc(i)),1))>1);
                if(length(x)>3)
                    set=set+1;
                end
            end
            setlist=[setlist set]; 
        end
        
        setlistBC=setlist;
        
        setlist=[];
        set=1;
        for i=1:size(startshc,1)-1
            if(i>1)
                x=find(diff(Fig(hci(startshc(i-1)):hci(startshc(i)),1))>1);
                if(length(x)>3)
                    set=set+1;
                end
            end
            setlist=[setlist set]; 
        end
        
        setlistHC=setlist;
        trajHinBC=cell(size(startsbc,1)-1,1);
        HittrajHinBC=cell(size(startsbc,1)-1,1);
        
        trajBC=cell(size(startsbc,1)-1,1);
        HittrajBC=cell(size(startsbc,1)-1,1);
        targlistBC=[];
        for q=1:setlistBC(length(setlistBC))
            for i=1:8
                File(file).setBC(q).BPBC{i}=[];
                File(file).setBC(q).SPBC{i}=[];
                File(file).setBC(q).MPBC{i}=[];
                File(file).setBC(q).EPBC{i}=[];
                File(file).setBC(q).HitBC{i}=[];
                File(file).setBC(q).BPHinBC{i}=[];
                File(file).setBC(q).SPHinBC{i}=[];
                File(file).setBC(q).MPHinBC{i}=[];
                File(file).setBC(q).EPHinBC{i}=[];
                File(file).setBC(q).HitHinBC{i}=[];
                
            end
        end%q
        for i=1:size(startsbc,1)-1
            index=bci(startsbc(i)):bci(startsbc(i+1)-1);
            x=Curs(index,:);
            trajBC{i,1}=x;
            ins=InSphere(index,1);
            HittrajBC{i,1}=x(find(ins>0.5),:);
            T=Tnum(index(ceil(length(index)/2)),1)
            targlistBC=[targlistBC T];
            File(file).setBC(setlistBC(i)).BPBC{T}=[File(file).setBC(setlistBC(i)).BPBC{T};x(1,:)];
            File(file).setBC(setlistBC(i)).SPBC{T}=[File(file).setBC(setlistBC(i)).SPBC{T};x(ceil(size(x,1)*.333),:)];
            File(file).setBC(setlistBC(i)).MPBC{T}=[File(file).setBC(setlistBC(i)).MPBC{T};x(ceil(size(x,1)*.666),:)];
            File(file).setBC(setlistBC(i)).EPBC{T}=[File(file).setBC(setlistBC(i)).EPBC{T};x(size(x,1),:)];
            if(ins(1))
                disp('first point of BCtrajectory is in sphere');
                ins(1)=0;
                %keyboard;
            end
            File(file).setBC(setlistBC(i)).HitBC{T}=[File(file).setBC(setlistBC(i)).HitBC{T};sum(ins)];
            x=HCposinterp(index,:);
            trajHinBC{i,1}=x;
            ins=InSphereHin(index,1);
            HittrajHinBC{i,1}=x(find(ins>0.5),:);
            File(file).setBC(setlistBC(i)).BPHinBC{T}=[File(file).setBC(setlistBC(i)).BPHinBC{T};x(1,:)];
            File(file).setBC(setlistBC(i)).SPHinBC{T}=[File(file).setBC(setlistBC(i)).SPHinBC{T};x(ceil(size(x,1)*.333),:)];
            File(file).setBC(setlistBC(i)).MPHinBC{T}=[File(file).setBC(setlistBC(i)).MPHinBC{T};x(ceil(size(x,1)*.666),:)];
            File(file).setBC(setlistBC(i)).EPHinBC{T}=[File(file).setBC(setlistBC(i)).EPHinBC{T};x(size(x,1),:)];
            File(file).setBC(setlistBC(i)).HitHinBC{T}=[File(file).setBC(setlistBC(i)).HitHinBC{T};sum(ins)];
            
        end
        
        trajHC=cell(size(startshc,1)-1,1);
        HittrajHC=cell(size(startshc,1)-1,1);
        targlistHC=[];
        for q=1:setlistHC(length(setlistHC))
            for i=1:8
                File(file).setHC(q).BPHC{i}=[];
                File(file).setHC(q).SPHC{i}=[];
                File(file).setHC(q).MPHC{i}=[];
                File(file).setHC(q).EPHC{i}=[];
                File(file).setHC(q).HitHC{i}=[];
                File(file).setHC(q).BPBinHC{i}=[];
                File(file).setHC(q).SPBinHC{i}=[];
                File(file).setHC(q).MPBinHC{i}=[];
                File(file).setHC(q).EPBinHC{i}=[];
                File(file).setHC(q).HitBinHC{i}=[];
                
            end
        end
        for i=1:size(startshc,1)-1
            index=hci(startshc(i)):hci(startshc(i+1)-1);
            x=Curs(index,:);
            trajHC{i,1}=x;
            ins=InSphere(index,1);
            HittrajHC{i,1}=x(find(ins>0.5),:);
            T=Tnum(index(ceil(length(index)/2)),1)
            targlistHC=[targlistHC T];
            File(file).setHC(setlistHC(i)).BPHC{T}=[File(file).setHC(setlistHC(i)).BPHC{T};x(1,:)];
            File(file).setHC(setlistHC(i)).SPHC{T}=[File(file).setHC(setlistHC(i)).SPHC{T};x(ceil(size(x,1)*.333),:)];
            File(file).setHC(setlistHC(i)).MPHC{T}=[File(file).setHC(setlistHC(i)).MPHC{T};x(ceil(size(x,1)*.666),:)];
            File(file).setHC(setlistHC(i)).EPHC{T}=[File(file).setHC(setlistHC(i)).EPHC{T};x(size(x,1),:)];
            
            if(ins(1))
                error('first point of HC trajectory is in sphere');
                ins(1)=0;
                %keyboard;
            end
            File(file).setHC(setlistHC(i)).HitHC{T}=[File(file).setHC(setlistHC(i)).HitHC{T};sum(ins)];
            
            
            x=cumsum(PV(index,:));
            trajBinHC{i,1}=x;
            ins=DistanceMag(x,ones(size(x,1),1)*targ(Tnum(index(ceil(length(index)/2)),1),:)*figsize);
            
            HittrajBinHC{i,1}=x(find(ins<indist),:);
            File(file).setHC(setlistHC(i)).BPBinHC{T}=[File(file).setHC(setlistHC(i)).BPBinHC{T};x(1,:)];
            File(file).setHC(setlistHC(i)).SPBinHC{T}=[File(file).setHC(setlistHC(i)).SPBinHC{T};x(ceil(size(x,1)*.333),:)];
            File(file).setHC(setlistHC(i)).MPBinHC{T}=[File(file).setHC(setlistHC(i)).MPBinHC{T};x(ceil(size(x,1)*.666),:)];
            File(file).setHC(setlistHC(i)).EPBinHC{T}=[File(file).setHC(setlistHC(i)).EPBinHC{T};x(size(x,1),:)];
            
            File(file).setHC(setlistHC(i)).HitBinHC{T}=[File(file).setHC(setlistHC(i)).HitBinHC{T};sum(ins)];
            
        end
        
        %=======================plotting
        fignum=1000
        oldset=1;
        figure(fignum)
        hold on
        title([namelist(day,:) 'BC']);
        for j=1: size(startsbc,1) -1
            set=setlistBC(j)
            
            if((file==filelist(1))&(set<3))
            else
                if(set~=oldset)
                    totalsets=totalsets+1;
                    oldset=set;
                end
                %if(totalsets<=11)
                if(targlistBC(j)<=4)
                    subplot(1,2,1)
                    xlabel('X');
                    ylabel('Y');
                    zlabel('Z');
                    hold on
                    v=trajBC{j,1};
                    plot3(v(:,1),v(:,2),v(:,3),ccode(targlistBC(j),:));
                    v=HittrajBC{j,1};
                    if(~isempty(v))
                        plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistBC(j),:));
                    end
                    
                    plot3([0;targ(targlistBC(j),1)*figsize],[0;targ(targlistBC(j),2)*figsize],[0;targ(targlistBC(j),3)*figsize],ccode(targlistBC(j),:),'LineWidth',5);
                    
                    VIEW(v1); 
                    
                    axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
                else
                    
                    subplot(1,2,2);
                    xlabel('X');
                    ylabel('Y');
                    zlabel('Z');
                    hold on
                    v=trajBC{j,1};
                    plot3(v(:,1),v(:,2),v(:,3),ccode(targlistBC(j)-4,:));
                    v=HittrajBC{j,1};
                    if(~isempty(v))
                        plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistBC(j)-4,:));
                    end
                    plot3([0;targ(targlistBC(j),1)*figsize],[0;targ(targlistBC(j),2)*figsize],[0;targ(targlistBC(j),3)*figsize],ccode(targlistBC(j)-4,:),'LineWidth',5);
                    VIEW(v1); 
                    axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
                end%if targ,4
                %end%if total sets
            end%if else set>2
            
        end%j
        
        %if(totalsets<=11)
        figure(fignum+100)
        hold on
        title([namelist(day,:) 'HC during BC file' num2str(file)]);
        for j=1: size(startsbc,1) -1
            set=setlistBC(j)
            
            if((file==filelist(1))&(set<3))
            else
                
                if(targlistBC(j)<=4)
                    subplot(1,2,1)
                    xlabel('X');
                    ylabel('Y');
                    zlabel('Z');
                    hold on
                    v=trajHinBC{j,1};
                    plot3(v(:,1),v(:,2),v(:,3),ccode(targlistBC(j),:));
                    v=HittrajHinBC{j,1};
                    if(~isempty(v))
                        % plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistBC(j),:));
                    end
                    
                    plot3([0;targ(targlistBC(j),1)*figsize],[0;targ(targlistBC(j),2)*figsize],[0;targ(targlistBC(j),3)*figsize],ccode(targlistBC(j),:),'LineWidth',5);
                    
                    VIEW(v1); 
                    
                    axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
                else
                    
                    subplot(1,2,2);
                    xlabel('X');
                    ylabel('Y');
                    zlabel('Z');
                    hold on
                    v=trajHinBC{j,1};
                    plot3(v(:,1),v(:,2),v(:,3),ccode(targlistBC(j)-4,:));
                    v=HittrajHinBC{j,1};
                    if(~isempty(v))
                        %  plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistBC(j)-4,:));
                    end
                    plot3([0;targ(targlistBC(j),1)*figsize],[0;targ(targlistBC(j),2)*figsize],[0;targ(targlistBC(j),3)*figsize],ccode(targlistBC(j)-4,:),'LineWidth',5);
                    VIEW(v1); 
                    axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
                end%if targ,4
            end%if else set>2
        end%j
        
        
        figure(fignum+200)
        hold on
        title([namelist(day,:) 'HC']);
        for j=1: size(startshc,1) -1
            set=setlistHC(j)
            
            
            
            if(targlistHC(j)<=4)
                subplot(1,2,1)
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                hold on
                v=trajHC{j,1};
                plot3(v(:,1),v(:,2),v(:,3),ccode(targlistHC(j),:));
                v=HittrajHC{j,1};
                if(~isempty(v))
                    plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistHC(j),:));
                end
                
                plot3([0;targ(targlistHC(j),1)*figsize],[0;targ(targlistHC(j),2)*figsize],[0;targ(targlistHC(j),3)*figsize],ccode(targlistHC(j),:),'LineWidth',5);
                
                VIEW(v1); 
                
                axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
            else
                
                subplot(1,2,2);
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                hold on
                v=trajHC{j,1};
                plot3(v(:,1),v(:,2),v(:,3),ccode(targlistHC(j)-4,:));
                v=HittrajHC{j,1};
                if(~isempty(v))
                    plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistHC(j)-4,:));
                end
                plot3([0;targ(targlistHC(j),1)*figsize],[0;targ(targlistHC(j),2)*figsize],[0;targ(targlistHC(j),3)*figsize],ccode(targlistHC(j)-4,:),'LineWidth',5);
                VIEW(v1); 
                axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
            end%if targ,4
        end%j
        
        figure(fignum+300)
        hold on
        title([namelist(day,:) 'BC during HC']);
        for j=1: size(startshc,1) -1
            set=setlistHC(j)
            
            
            
            if(targlistHC(j)<=4)
                subplot(1,2,1)
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                hold on
                v=trajBinHC{j,1};
                plot3(v(:,1),v(:,2),v(:,3),ccode(targlistHC(j),:));
                v=HittrajBinHC{j,1};
                if(~isempty(v))
                    plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistHC(j),:));
                end
                
                plot3([0;targ(targlistHC(j),1)*figsize],[0;targ(targlistHC(j),2)*figsize],[0;targ(targlistHC(j),3)*figsize],ccode(targlistHC(j),:),'LineWidth',5);
                
                VIEW(v1); 
                
                axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
            else
                
                subplot(1,2,2);
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                hold on
                v=trajBinHC{j,1};
                plot3(v(:,1),v(:,2),v(:,3),ccode(targlistHC(j)-4,:));
                v=HittrajBinHC{j,1};
                if(~isempty(v))
                    plot3(v(:,1),v(:,2),v(:,3),ccodes(targlistHC(j)-4,:));
                end
                plot3([0;targ(targlistHC(j),1)*figsize],[0;targ(targlistHC(j),2)*figsize],[0;targ(targlistHC(j),3)*figsize],ccode(targlistHC(j)-4,:),'LineWidth',5);
                VIEW(v1); 
                axis([-figsize*2 figsize*2 -figsize*2 figsize*2 -figsize*2 figsize*2]);
            end%if targ,4
        end%j
        %end%if total sets
        %eval(['save C:\SMOTHER\Biggunitfiles40172001\VRBalistic\' name 'EP'  ' File']);

        save([name 'interp' num2str(file)])
        
        
        display([namelist(day,:) ' at the end of file' num2str(file)]);
        %keyboard
        %close all
    end%files
    display(namelist(day,:));
    %keyboard
    
end%day
