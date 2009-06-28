% Description:
% The functions listed here will basically calculate power using FFT/AR/BP.
% The calculated power samples will be divided into epochs based on a
% trigger event.
% The trigger event is necessary to line up the trials for e.g. to account
% for reaction time jitter.
% The trials/epochs will be averaged (global average), subtracted from all
% trials, and a spectrogram of the trial average (all trials of a particular event) 
% from a particular channel will be plotted.


% Load data
loaded = load('bootstrap_data','behavior','syncs');
neuron_combos = [1 6; 1 7; 1 8; 3 4; 5 7; 6 7];
X = [];
for n = 1:size(neuron_combos)
    row = neuron_combos(n,1);
    col = neuron_combos(n,2);
    X(end+1,:) = squeeze(loaded.syncs(row,col,:));
end
Y = loaded.behavior';
clear loaded
 
% Necessary parameters
fl = 1; %Hz, lower frequency bound
fh = 10; %Hz, upper frequency bound
Extract.reref_mtx = eye(size(X,1)); %rereference matrix. set to eye to include all channels as recorded
Extract.fseeg = 1/0.05;%Hz, sampling rate of data
Extract.feature='FFT'; % Can be AR/FFT/BP
Extract.W=1;
Extract.Shift=0.05; % feature extraction window length and shift
Extract.mo=1:60; % Required parameter for AR - specifies the model order
Extract.fr_avg=1; 
Extract.fr = (0:(Extract.fseeg/2))*Extract.fseeg;
% If you want to average together some of the frequency bands specicfy the
% number of bands to average together. For example 2 will average the first
% two, then the next two and so on.
Extract.idx=[]; % Channels/Frequency elements to include in the final power matrix.
% The function CalcPower defines this based on fr_avg parameter.
Extract.filter_bp=[fl fh]; % Frequency band to be included in the final power matrix;
Extract.fr=Extract.fseeg*([0:(Extract.W*Extract.fseeg)/2]./(Extract.W*Extract.fseeg));
Extract.fslabel = Extract.fseeg;


% Calculate Power
% Matrix P will be of dimension Tx(N*f).
% T=Time samples
% N= number of channels in the recording array.
% f= (freq_band)/fr_avg. freq_band=fl-fh;
[P,L]=CalcPower(X(:,:),Y',Extract);

%%%DEBUG
keyboard

% Generate the trigger signal and corresponding event list ...
% I usually have a function here that extracts the trigger time points and
% the corresponding event laebl for me.
% Trig_Cue=[Eventlabel Index to time point in the experiment];
% Trig_T=Time point at which the event occured in s.
% Extract.options=defines the time period of an epoch/trial.

% Extract epochs
[Epochs,Cue,tempP,tempL]=ExtractEpochs(P,L,Trig_T,Trig_Cue,fsEEG,fsCue,Extract.options);

% Calculating the average over all trials for normalization 
T_M(:,:)=mean(Epochs(:,:,:),1); 

% Normalizing the trials using global average
clear temp;
for i=1:size(Epochs,1)
    for j=1:size(Epochs,3)
        temp(1,:)=Epochs(i,:,j);
        T_s(:,j)=std(Epochs(:,:,j),1);
        Z_Scored_P(i,:,j)=(temp'-T_M(:,j))./T_s(:,j);
    end    
end
clear temp T_M T_s


% Spectrogram referenced to EMG onset
t=Extract.options(2):Extract.Shift:Extract.options(3); % Definition of epoch/trial w.r.t to trigger event.
figure1=figure('Color',[0.8902 0.9843 0.9922]);
axes('FontSize',22,'Parent',figure1)
clear temp;numF=size(P,2)./length(Extract.reref_mtx);% Frequency bands included in the power spectrum matrix;
idx=(Cs-1)*numF+(1:numF); % Channel chosen for plotting spectrogram.
temp(:,:)=mean(Z_Scored_P(Cue(:,1)==Extract.class(2),:,idx),1); % Averaging all the trials of a particular type.
imagesc(t(1:end-1),(1:numF)*Extract.fr_avg,temp');clear temp;
xlabel('Time(s)','FontSize',16);ylabel('Frequency(Hz)','FontSize',16);
