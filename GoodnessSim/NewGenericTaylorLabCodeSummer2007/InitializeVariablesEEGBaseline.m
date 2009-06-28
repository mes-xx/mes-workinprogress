%%%% Assigns random weights ranging from -1 to +1 for all channels
%% And initializes matrices to hold past weights, success rates, and block times
%% Initialize work data variables and buffers
eval(Funk.ConvertSecToSamples);
eval(Funk.DefineWriteLine);
SubFreqIndex=zeros(TotalNumFreqBin, decode.num_RerefChan);
SubFreqIndex(SigProc.freq_bin ,:)=1;
SubFreqIndex=find(reshape( SubFreqIndex , 1,decode.num_RerefChan*TotalNumFreqBin )==1);%index into long vector of Freq bins on all channels
%Rmat=[cos(45*pi/180) -1*sin(45*pi/180);sin(45*pi/180) cos(45*pi/180)];
%VR.modeflag=1;
% event.BC_flag=0; % brain control flag; 1=brain-controlled cursor 0=no brain control
% event.code=0; % holds current event code
% event.BlockNum=0; %% counts number of blocks during recording session
% %block_cnt=0; % counts number of blocks during recording session
% KeepRunningFlag=1;
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
Parameters.std2power=ones(1,decode.num_totalchan);
Parameters.meanpower=zeros(1,decode.num_totalchan); 
SigProc.FreqBinsVals=TDT.sample_rate.*SigProc.freq_bin/decode.fft_size;

a = exist([OutName 'params']);
if a~=7
    mkdir([OutName 'params'])
end
VR.target_num=0;
eval(Funk.CursorFileColumnRecord);
save([OutName 'params\ParametersStart'], 'Parameters','VR', 'SigProc','decode','timing','Funk');
