%%%% Assigns random weights ranging from -1 to +1 for all channels
%% And initializes matrices to hold past weights, success rates, and block times
%% Initialize work data variables and buffers
eval(Funk.ConvertSecToSamples);
SubFreqIndex=zeros(TotalNumFreqBin, decode.num_RerefChan);
SubFreqIndex(SigProc.freq_bin ,:)=1;
SubFreqIndex=find(reshape( SubFreqIndex , 1,decode.num_RerefChan*TotalNumFreqBin )==1);%index into long vector of Freq bins on all channels
%Rmat=[cos(45*pi/180) -1*sin(45*pi/180);sin(45*pi/180) cos(45*pi/180)];
%VR.modeflag=1;
% event.BC_flag=0; % brain control flag; 1=brain-controlled cursor 0=no brain control
% event.code=0; % holds current event code
VR.BlockNum=0; %% counts number of blocks during recording session
% %block_cnt=0; % counts number of blocks during recording session
% KeepRunningFlag=1;
UpdateBlockNum=1; %Counts the number of times the weights are updated
iUpdateBlock=mod(UpdateBlockNum+Parameters.NumBlocksHeld-1,Parameters.NumBlocksHeld)+1;
LoopIndex=0;% counts number of Time GetData is called
% UpdateBlockNum=1; %Counts the number of times the weights are updated
% iUpdateBlock=1
TDT.last_index=-1;
timing.now=0;%In samples
% VR.cursor_position=[0 0 0];
% VR.target_position=[0 0 0];
data.raw_buf=zeros(TDT.size_buffer/TDT.num_chan,TDT.num_chan); % ring buffer that holds raw data, corresponds exactly to buffer on Pentusa; it may be useful to change this buffer so that its size is independent from the buffer size on the pentusa
data.raw_current=zeros(decode.fft_size,TDT.num_chan); % buffer that holds current analysis window
%data.time_buf=zeros(decoding.size_buffer,1); % ring buffer that holds the corresponding time (in samples) for smoothed and normalized buffers
timing.mean_windowbyTarg=ceil(timing.mean_window/VR.num_targets);
Parameters.mean_windowbyTarg=timing.mean_windowbyTarg;
data.power_buffer= ones(timing.mean_windowbyTarg, decode.num_totalchan,VR.num_targets)*NaN; %ring buffer to hold the rereferenced power data (used frequencies only) for averaging
% note this version is just keeping the same set of ring buffers for each
% mode and it assumes the same number of dimensions used per mode...This
% should be changed!!
TargetTally=zeros(VR.num_targets,1);%keeps track of which targets were on for more accurate normlization
iTargetTally=zeros(VR.num_targets,1);
if(WriteRaw)
    Raw(WriteRaw)=struct('LoopIndex',[],'TDTLast_Index',[],'TDTsize_download', [],'VRtarget_position',[],'datatemp' ,[]);
end

SigProc.FreqBinsVals=TDT.sample_rate.*SigProc.freq_bin/decode.fft_size;
SoFarSoGoodFlag=1;
WeightInitializedFlag=0;
rand('state',sum(100*clock));
Parameters.Wp=(rand(decode.num_totalchan,VR.num_dim)-0.5)*2; % current weights for positive normalized values
Parameters.Wn=(rand(decode.num_totalchan,VR.num_dim)-0.5)*2; % current weights for negative normalized values
Parameters.Phit=zeros(1,Parameters.NumBlocksHeld); % past N blocks' percent hits
Parameters.BlockTime=ones(1,Parameters.NumBlocksHeld)*realmax; % time it took to finish previous blocks
Parameters.EndDistance=ones(1,Parameters.NumBlocksHeld)*realmax;
Parameters.Mag= ones(Parameters.NumBlocksHeld, VR.num_dim); % holds the estimated magnitude of movement in each dimension
Parameters.TargetRad= VR.TargRad;
%%%
%Begin new variables for goodness calculations
% all hold different measures of performance for specified number of blocks
Parameters.MovementErrorAngle = ones(1,Parameters.NumBlocksHeld)*realmax;
Parameters.EndDistanceMax = ones(1,Parameters.NumBlocksHeld)*realmax;
Parameters.PositionErrorAngle = ones(1,Parameters.NumBlocksHeld)*realmax;
Parameters.EndPositionErrorAngle = ones(1,Parameters.NumBlocksHeld)*realmax;
Parameters.MeanA = ones(1,Parameters.NumBlocksHeld)*realmax;
%End new variables for goodness calculations
%%%

ParametersOld=load([ Parameters.BaselineFilePath 'ParametersFinal.mat']);
try
 load([ Parameters.BaselineFilePath 'Neurons.mat']);
catch
    disp('could not load Neurons.mat');
end
            
Parameters.meanpower=zeros(size(ParametersOld.Parameters.meanpower));

Parameters.std2power=ParametersOld.Parameters.std2power;

Parameters.MeanPowerByTarget=ParametersOld.Parameters.MeanPowerByTarget;

Parameters.estNpower=ParametersOld.Parameters.estNpower;


VR.target_num=0;
UpdateBlockNum=1;
VR.BC_flag=0;
TDT.size_download=0;
wV=zeros(1,VR.num_dim);
data.normalized=zeros(size(Parameters.meanpower));
for i= 1:decode.num_totalchan
    for j=1:VR.num_targets
        data.power_buffer(:,i, j)=Parameters.MeanPowerByTarget(j,i);
    end
end
%================
if size(Parameters.Wp,3)<Parameters.NumBlocksHeld
    for count=size(Parameters.Wp,3)+1:Parameters.NumBlocksHeld
        Parameters.Wp(:,:,count)=Parameters.Wp(:,:,1); % past N blocks' weights
        Parameters.Wn(:,:,count)=Parameters.Wn(:,:,1);
    end;
end

Parameters.Drift=zeros(1,VR.num_dim);
for i=1:decode.num_totalchan

    for j=1:VR.num_dim
        Parameters.Drift(1,j)=Parameters.Drift(1,j)+Parameters.Wp(i,j,1)*0.5*Parameters.estNpower(i) - Parameters.Wn(i,j,1)*0.5*Parameters.estNpower(i);
    end
end
%These variables are accumulated (summed) between updates and then divided
%by UpdateTally to get the mean values betweeen updates.
dEstNpower=zeros(decode.num_totalchan,1);%This Sums normalized power for weight update
dWp=zeros(decode.num_totalchan,VR.num_dim);%This Sums errors for weight update
dWn=zeros(decode.num_totalchan,VR.num_dim);%This Sums errors for weight update
dMag=zeros(1,VR.num_dim); %This sums magnitude of movements in each direction
%dRMag=zeros(1,VR.num_dim); %This sums magnitude of Rotated movements in each XYZ direction to account for correlations

dAbsErrorP=zeros(decode.num_totalchan,VR.num_dim);
dAbsErrorN=zeros(decode.num_totalchan,VR.num_dim);
UpdateTally=0;
UpdateTallyP=ones(decode.num_totalchan,1)*eps(0);
UpdateTallyN=ones(decode.num_totalchan,1)*eps(0);
Vold=zeros(1,VR.num_dim);
%Anything that is written to the cursor file needs to be initialized before
%here and to the correct eventual size.
eval(Funk.CursorFileColumnRecord);
a = exist([OutName 'params']);
if a~=7
    mkdir([OutName 'params'])
end

save([OutName 'params\ParametersStart'], 'Parameters','VR', 'SigProc','decode','timing','Funk');

