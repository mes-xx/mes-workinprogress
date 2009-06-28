%%%% Download available data from Pentusa MCserStore buffer of any size
%%%% greater than TDT.min_download
%% Same as RetrieveTDTdataMCflex, except that it puts the downloaded data
%% directly into the Matlab data buffer that holds the same amount of data
%% as the buffer on the running RCO file
function [data_buffer,x,last_index,size_download]=RetrieveTDTdataMCflexBuf(TDT,min_download,data_buffer)
% disp('running retriveTDTdataMCFlexBuff');
%% Retrieve current buffer index from TDT
cur_index=invoke(TDT.RP, TDT.call_GetTag, TDT.tag_sIndex);

%% If last index equals -1 then start from any position in buffer
if TDT.last_index==-1,
    TDT.last_index=cur_index;
end;

size_download=(cur_index-TDT.last_index)/TDT.num_chan;

%% Wait in this loop until there is more than the minimum download size of
%% data available or until the MCserStore begins to write to the beginning
%% of the buffer
while( size_download>=0 && size_download<min_download),
    cur_index=invoke(TDT.RP, TDT.call_GetTag, TDT.tag_sIndex);
    size_download=(cur_index-TDT.last_index)/TDT.num_chan;
end;

%% If MCserStore resets to write to beginning of buffer, than download size
%% is the amount of data between the last download and the end of the
%% MCserStore
if size_download<0,
    size_download=(TDT.size_buffer-TDT.last_index)/TDT.num_chan;
end;

%% Retrieve data from TDT serial buffer
x=double(invoke(TDT.RP, TDT.call_ReadTag, TDT.tag_data, TDT.last_index, size_download*TDT.num_chan));
data_buffer(TDT.last_index/TDT.num_chan+1:TDT.last_index/TDT.num_chan+size_download,:)=reshape(x,TDT.num_chan,size_download)';

%% Update last index which equals the first sample to be read in the next
%% download
last_index=mod((TDT.last_index+size_download*TDT.num_chan),TDT.size_buffer);

%% If need more data to obtain min download amount of data, get more data
if size_download<min_download,
    TDT.last_index=last_index;
    [data_buffer x2 last_index size_download2]=RetrieveTDTdataMCflexBuf(TDT,min_download-size_download,data_buffer);
    x=[x x2];
    size_download=size_download+size_download2;
end;

return;