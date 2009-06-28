%%%% Retrieves data from Pentusa, rereferences data, processes data using
%%%% FFT's, smoothes FFT data, normalizes data.
%%%% Updates matlab data buffers and time indices.
%%%% Saves raw, smoothed, normalized data, BC flag to file.

%% If TDT.last_index equals -1, we aren't looking at consecutive data from
%% the last acquisition, therefore, reset recent data buffers
LoopIndex=LoopIndex+1;
if TDT.last_index==-1,
    data.raw_buf=zeros(TDT.size_buffer/TDT.num_chan,TDT.num_chan);
end;

%% Retrieve a minimum amount of data from Pentusa
[data.raw_buf datatemp TDT.last_index TDT.size_download]=RetrieveTDTdataMCflexBuf(TDT,timing.loop_interval,data.raw_buf);
eval(Funk.WriteRawData)

% disp(TDT.last_index/TDT.num_chan+1);

%% Pull recent data for analysis from raw data buffer (current data for analysis)
data.raw_current=Pull_Data(data.raw_buf,[],TDT.last_index/TDT.num_chan,decode.fft_size,[],TDT.size_buffer/TDT.num_chan);


%-------MODE SWITCH---------

    loop_interval=timing.loop_interval; % Need to fix this in my code (Get_ModeSwitch_stationary)
    
    % For Arm EMG subtract first two channel and make as channel 5
    data.raw_current(:,5)=data.raw_current(:,1)-data.raw_current(:,2);

    Get_ModeSwitch_stationary
    if ~exist('mode_flg')
        mode_flg=1;
    end

    if ModeSwitch_flg
       disp('MODE SWITCH')
    end
    
    mode_flg = Get_Current_Mode(mode_flg,ModeSwitch_flg,[1 2]);

    % DJC makes Target Purple (also keeps blue on for 2 sample lengths)
    if mode_flg==2
        setfield(VR.world.TargetColor, 'diffuseColor', [1 0 1]);
    else % if not DJC then keep target same color (THIS WILL NEED BE BE FIXED)
        setfield(VR.world.TargetColor, 'diffuseColor', [.66 1 1]);
    end

    vrdrawnow;  % Apply appropirate color change
%-------END MODE SWITCH---------

    %% Data processing

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% EEG FFT PROCESSING
   % data.reref_current=data.raw_current*SigProc.ReRefMat;
%     
%     if decoding.use_AR==1,
%         h=spectrum.burg(4);
%         pspec=psd(h,x_prime,'Fs',610,'nFFT',64);
%     else,
TargetTally(VR.target_num)=TargetTally(VR.target_num)+1;
iTargetTally(VR.target_num)=mod(TargetTally(VR.target_num),timing.mean_windowbyTarg)+1;
data.temp.X1=(fft(data.raw_current*SigProc.ReRefMat,decode.fft_size))';
data.temp.Pxx1=data.temp.X1.*conj(data.temp.X1)/decode.fft_size;
if decode.LogTransform
    data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)=log(reshape(data.temp.Pxx1(:,SigProc.freq_bin)',1,decode.num_totalchan)); % extract all freq bins store data in recent data buffer to be smoothed
    
else
    data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)=reshape(data.temp.Pxx1(:,SigProc.freq_bin)',1,decode.num_totalchan); % extract all freq bins store data in recent data buffer to be smoothed
end
%These steps below here should be done to all types of data to be used for
%decoding or writen to file. If there is more than one type of data (e.g. LFPs & rates) all should be concatenated together in the
%data.normalized variable. They could be concatenated together before that
%when calculating the  mean-by-target and mean-across-targets and an
%example is shown below.
timing.now=timing.now+TDT.size_download;
if~mod(LoopIndex,timing.mean_update_interval)
    for i=1:VR.num_targets
        Parameters.MeanPowerByTarget(i,:)=nanmean(data.power_buffer(:,:, i));%  could concatenate additional inputs in here e.g. nanmean([data.power_buffer(:,:, i) data.rate_buff(:,:,i)]);
    end
    Parameters.meanpower=nanmean(Parameters.MeanPowerByTarget);
end
% for concatenating LFps & rates, you would need to do something similar here e.g. 
%data.normalized=([data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num) ; data.rate_buffer(iTargetTally(VR.target_num),:, VR.target_num)]-Parameters.meanpower)./Parameters.std2power;
data.normalized=(data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)-Parameters.meanpower)./Parameters.std2power;
