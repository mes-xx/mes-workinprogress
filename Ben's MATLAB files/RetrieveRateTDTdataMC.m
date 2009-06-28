%%%% Download Bin Rate data from multichannel(MC) buffer to MATLAB
function [BinCountVect,last_index]=RetrieveRateTDTdataMC(TDT)

%% Retrieve current rate buffer index from TDT
cur_index=invoke(TDT.RP, TDT.call_GetTag, TDT.tag_sRate);

%% If we don't need consecutive data, set TDT.last_index=-1,
%% so that data will be obtained starting from the current buffer index
%% position
if TDT.last_index==-1,
    TDT.last_index=cur_index;
end;

%% Check buffer index to see if Matlab is falling behind
%% For each new set of data writen to the MC buffer, the index will
%% increment by the number of channels put into the buffer.
%% So this checks to see if no data has been added to the buffer or one set
%% of data has been added.  If neither are true, than matlab is falling
%% behind.
if ~(cur_index==TDT.last_index||cur_index==mod((TDT.last_index+TDT.num_chan),TDT.size_buffer)),
    fprintf('*');
end;

%% Wait until buffer index is past the index of the last data downloaded
while(cur_index==TDT.last_index),
    cur_index=invoke(TDT.RP, TDT.call_GetTag, TDT.tag_sRate);
end;

%% Read back from the buffer - binned rate info for 16 channels.
%% The incoming data is in 32 bit integer format.
%% Convert to double float so you can both bitand() and multiply the numbers.
BinData=double(invoke(TDT.RP, TDT.call_ReadTag, TDT.tag_dRate, TDT.last_index, TDT.num_chan));

size(TDT.ShiftMat)
size(bitand(TDT.AndMask,[BinData;BinData;BinData;BinData]))
%% Mask and shift appropriately with defined matricies.
%% BinCounts has columns 1-16 by channel, and rows 1-4 by sort code.
%% The units of BinCounts is spikes per bin.
BinCounts= TDT.ShiftMat*bitand(TDT.AndMask,[BinData;BinData;BinData;BinData]);
BinCountVect=BinCounts(:)';

%% Update last index which equals the first sample to be read in the next
%% download
last_index=mod((TDT.last_index+TDT.num_chan),TDT.size_buffer);

return;