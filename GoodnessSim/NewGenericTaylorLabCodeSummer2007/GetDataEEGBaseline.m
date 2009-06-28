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
timing.now=timing.now+TDT.size_download;
if~mod(LoopIndex,timing.mean_update_interval)
    meanlist=zeros(VR.num_targets,decode.num_totalchan);
    for i=1:VR.num_targets
        Parameters.MeanPowerByTarget(i,:)=nanmean(data.power_buffer(:,:, i));
    end
    Parameters.meanpower=nanmean(Parameters.MeanPowerByTarget);
end
% 
% data.normalized=(data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)-adaptive.meanpower)./adaptive.std2power;
