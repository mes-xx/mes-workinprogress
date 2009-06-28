% ===================================
% Model of ideal offline OLE where feedback is not an issue, i.e. targets
% are standard [ 1 1; -1 1; 1 -1; -1 -1]. Simulate dx and dy with the
% given equations and generate fake 40-time-point trajectories.

%%%%%%%%%%%%%
%Andy-ish data (unequal information in X vs. Y)
clear all
close all
figure

A=1; %variance (noise) in X 
B=1; % variance (noise) in Y
C=2;  %information in X 
D=.3; % information in Y


L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    dX_fake=[dX_fake C*targs(rnd_targ(i),1)*ones(1,L_traject) + A*randn(1,L_traject)];
    dY_fake=[dY_fake D*targs(rnd_targ(i),2)*ones(1,L_traject)+ B*randn(1,L_traject)];
end
normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;




for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('Simulated Neural Data  (unequal information in X vs. Y)');

%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%correlated noise; equal information in X&Y; symmetric in X&Y
clear all
figure

A=1; %variance (noise) in X 
B=1; % variance (noise) in Y
C=0.3; %information in X 
D=0.3; % information in Y
Pcor=.5 % zero implies noise is independent; 1 implies noise in X=noise in Y
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    dX_fake=[dX_fake C*targs(rnd_targ(i),1)*ones(1,L_traject) + noiseX];
    dY_fake=[dY_fake D*targs(rnd_targ(i),2)*ones(1,L_traject)+ (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end
normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('Simulated Neural Data correlated noise');

%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%Asymetric information in X
clear all
figure

A=.15; %variance (noise) in X 
B=.15; % variance (noise) in Y
C=0.06; %information in X 
D=0.06; % information in Y
Pcor=0 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=3
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake D*targs(rnd_targ(i),2)*ones(1,L_traject)+ (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('Simulated Neural Data asymetric in X');

%%%%%%%%%%%%%=




%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%%equal but Asymetric information in X & in Y
clear all
figure

A=.15; %variance (noise) in X 
B=.15; % variance (noise) in Y
C=0.06; %information in X 
D=0.06; % information in Y
Pcor=0 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=3
ASymScaleY=3
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    
    Yinfo=D*targs(rnd_targ(i),2)*ones(1,L_traject);
    Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake Yinfo + (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('equal but Asymetric information in X & in Y');

%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%%equal but Asymetric information in X & in Y with correlations
clear all
figure

A=.15; %variance (noise) in X 
B=.15; % variance (noise) in Y
C=0.06; %information in X 
D=0.06; % information in Y
Pcor=.4 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=2
ASymScaleY=2
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    
    Yinfo=D*targs(rnd_targ(i),2)*ones(1,L_traject);
    Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake Yinfo + (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('equal but Asymetric information in X & in Y with Correlations');

%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%%equal but Asymetric information in X only with correlations
clear all
figure

A=.15; %variance (noise) in X 
B=.15; % variance (noise) in Y
C=0.06; %information in X 
D=0.06; % information in Y
Pcor=.4 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=3
ASymScaleY=1
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    
    Yinfo=D*targs(rnd_targ(i),2)*ones(1,L_traject);
    Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake Yinfo + (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('equal but Asymetric information in X only with Correlations');


%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%%'unequal informaiton in X vs. Y  with Correlations'
clear all
figure

A=.04; %variance (noise) in X 
B=.04; % variance (noise) in Y
C=0.04; %information in X 
D=0.01; % information in Y
Pcor=.5 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=1
ASymScaleY=1
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    
    Yinfo=D*targs(rnd_targ(i),2)*ones(1,L_traject);
    Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake Yinfo + (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('unequal informaiton in X vs. Y  with Correlations');

%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%%'unequal informaiton in X vs. Y  with Correlations and asymmetry in X'
clear all
figure

A=.05; %variance (noise) in X 
B=.05; % variance (noise) in Y
C=0.04; %information in X 
D=0.01; % information in Y
Pcor=.5 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=2
ASymScaleY=1
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    
    Yinfo=D*targs(rnd_targ(i),2)*ones(1,L_traject);
    Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake Yinfo + (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('unequal informaiton in X vs. Y  with Correlations and asymmetry in X');

%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%==============================================================
%%%%%%%%%%%%%=
%%'unequal informaiton in X vs. Y  with Correlations and asymmetry in Y'
clear all
figure

A=.05; %variance (noise) in X 
B=.05; % variance (noise) in Y
C=0.04; %information in X 
D=0.01; % information in Y
Pcor=.5 % zero implies noise is independent; 1 implies noise in X=noise in Y
ASymScaleX=1
ASymScaleY=2.5
L_traject=40;
N_traject=180;
axis_array= [-1* ceil(L_traject*1.5) ceil(L_traject*1.5) -1*ceil(L_traject*1.5) ceil(L_traject*1.5)];

targs=[1 1; -1 1; 1 -1; -1 -1]/sqrt(2);
rand('state',sum(100*clock));
rnd_targ=ceil(rand(1,N_traject)*4);

dX_fake=[];
dY_fake=[];

for i=1:N_traject
    noiseX=A*randn(1,L_traject);
    Xinfo=C*targs(rnd_targ(i),1)*ones(1,L_traject);
    Xinfo(find(Xinfo>0))=Xinfo(find(Xinfo>0))*ASymScaleX;
    
    Yinfo=D*targs(rnd_targ(i),2)*ones(1,L_traject);
    Yinfo(find(Yinfo>0))=Yinfo(find(Yinfo>0))*ASymScaleY;
    dX_fake=[dX_fake Xinfo + noiseX];
    dY_fake=[dY_fake Yinfo + (1-Pcor)*B*randn(1,L_traject)+Pcor*noiseX];
end

normX=mean(abs(dX_fake));
normY=mean(abs(dY_fake));
dX_fake=dX_fake/normX;
dY_fake=dY_fake/normY;

for i=1:N_traject
    for j=1:L_traject
        k=(i-1)*L_traject+j;
        fake_traject(1,k)=sum(dX_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
        fake_traject(2,k)=sum(dY_fake((i-1)*L_traject+1:(i-1)*L_traject+j));
    end
end
% Simulated data ==================
ccode=['r-';'g-';'c-';'b-'];
ccodes=['k.';'k.';'k.';'k.'];


for i=1:N_traject
        plot(fake_traject(1,(i-1)*L_traject+1:i*L_traject),fake_traject(2,(i-1)*L_traject+1:i*L_traject), ccode(rnd_targ(i),:));
        hold on
end
axis(axis_array)
axis square
title('unequal informaiton in X vs. Y  with Correlations and asymmetry in Y');
