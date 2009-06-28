LoopIndex = LoopIndex + 1;
while (HiResTimer('getElapsedTime') - VR.startTime < (timing.loop_intervalS - 0.002))
end
%Determine index of buffer, to pull the last nChan values, corresponding
% to nChan channels, with rates for the 4 sort codes contained in the 4 bytes of each 32
% bit integer for each channel.
Buf_offset=invoke(TDT.RP,'GetTargetVal',[TDT.Dev{1} '.rt_Index'])-TDT.num_chan;

%Read back from the buffer - binned rate info for nChan channels.
%The incoming data is in 32 bit integer format.
%Convert to double float so you can both bitand() and multiply the numbers.
BinData=uint32(invoke(TDT.RP,'ReadTargetV',[TDT.Dev{1} '.rt_Data'],Buf_offset,TDT.num_chan));

% calculate how much time has elapsed since the last set of data was read
VR.loopTime = HiResTimer('getElapsedTime')-VR.startTime;

% add elapsed time to timing.now
timing.now=HiResTimer('getElapsedTime');
if (VR.BadMonkeyFlag == 1)
	if (VR.BC_flag == 1)
		VR.BC_flag = 0;
		timing.BadMonkeyTime = timing.BadMonkeyTime + VR.loopTime;
		
	else
		timing.now = timing.BadMonkeyStart;
	end
end
	

% trigger the TDT to reset the binRate element
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.ResetFiring'], TDT.ResetFiring);

%set a marker in the TDT Tank
% now change state to whatever we want
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.stateValue'], LoopIndex);
% set stateReady high so OpenEx records new state value to tank
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.stateReady'], 1);
% stateReady should always be low before changing state
invoke(TDT.RP, 'SetTargetVal', [TDT.Dev{1} '.stateReady'], 0);

TDT.ResetFiring = 2 - TDT.ResetFiring;

% start the timer for the next interval
VR.startTime = HiResTimer('getElapsedTime');

% calculate bin rates
BinCounts= TDT.ShiftMat*double(bitand(TDT.AndMask,[BinData;BinData;BinData;BinData]));
BinRates = BinCounts ./ VR.loopTime;

% add 1 to the count for the current target
TargetTally(VR.target_num)=TargetTally(VR.target_num)+1;

% add 1 to the ring buffer index for the current target number
iTargetTally(VR.target_num)=mod(TargetTally(VR.target_num),timing.mean_windowbyTarg)+1;

% save the power (rates) for the current target into the power buffer
data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num) = reshape(BinRates(find(SigProc.SpReRefMat == 1)), 1, []);


% if the Loop index modulus the mean update interval == 0 (i.e. it is time
% to update the mean power), then iterate through the targets and calculate
% the mean power for the input signals for each target
if~mod(LoopIndex* timing.loop_intervalS, timing.mean_update_intervalS)
   % Parameters.std2power=zeros(1,decode.num_totalchan);
    for i=1:VR.num_targets
        Parameters.MeanPowerByTarget(i,:)=nanmean(data.power_buffer(:,:, i));%  could concatenate additional inputs in here e.g. nanmean([data.power_buffer(:,:, i) data.rate_buff(:,:,i)]);
      %  Parameters.std2power= Parameters.std2power+2*nanstd(data.power_buffer(:,:,i));
	end
	% take the mean of the means by target to get the overall mean
    Parameters.meanpower=nanmean(Parameters.MeanPowerByTarget);
     %Parameters.std2power= Parameters.std2power/VR.num_targets;
end

% normalize the power data by subtracting the overall mean and dividing by
% the standard deviation of the baseline data
data.normalized=(data.power_buffer(iTargetTally(VR.target_num),:, VR.target_num)-Parameters.meanpower)./Parameters.std2power;
TDT.size_download=1;

