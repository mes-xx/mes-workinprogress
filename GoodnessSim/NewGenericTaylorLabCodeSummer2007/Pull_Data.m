%% This function pulls data out of a 2D ring data buffer, 'data_in' (N x M)
%% N is the buffer index
%% M is the number of channels or whatever in the buffer

%% One can either specify the beginning and end indices of the data that
%% you want pulled from the buffer:
%% x=Pull_Data(data_buf,30,15,[],[],50)
%% pulls the data beginning from 30 wrapping around to 15 from data_buf
%% which is of size 50xM

%% OR you can specify the end point of the buffer and the amount of data
%% you want from the buffer which might wrap around
%% x=Pull_Data(data_buf,[],15,36,[],50)
%% this extracts the same data as above

%% 'data_use' is a vector of 1's and 0's of length N that corresponds to data
%% that is wanted from the buffer
%% use this if you have BC_buf and only want the data extracted from a
%% buffer during brain control
%% x=Pull_Data(data_buf,[],15,36,BC_buf,50)
%% this extracts the same data as above, but only the points that have a 1
%% in the corresponds BC_buf


function data_out=Pull_Data(data_in,pos_start,pos_end,output_length,data_use,size_buffer);

if isempty(pos_start),
    pos_start=pos_end-output_length+1;
    if pos_start<1,
        pos_start=pos_start+size_buffer;
    end;
end;

if isempty(data_use),
    data_use=ones(size(data_in));
end;

if isempty(size_buffer),
    size_buffer=size(data_in,1);
end;

if pos_end>pos_start,
    
    data_out=data_in(pos_start:pos_end,:);
    data_out=data_out(find(data_use(pos_start:pos_end)==1),:);
    
else,
    
    data_out1=data_in(pos_start:size_buffer,:);
    data_out1=data_out1(find(data_use(pos_start:size_buffer)==1),:);
    
    data_out2=data_in(1:pos_end,:);
    data_out2=data_out2(find(data_use(1:pos_end)==1),:);
    
    data_out=[data_out1;data_out2];

end;