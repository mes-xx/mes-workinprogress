% This file:
%  1. Reads the strobe waveform from the tank
%  2. Finds the distribution of interspike timings
%  3. Calculates an initial triangle width
%%%%
% Parameters:
%  TankName = name of the tank holding strobe data
%  BlockName = name of block to read from TankName
%  StoreName = name of store with strobe data in tank
%  SyncThresh = how many standard deviations from mean of
%               interspike spacing to consider synced
%%%%
% Variables:
%  TT = TTank ActiveX control
%%%%

Parameters.TankName  = 'sync';
Parameters.BlockName = 'Block-1';
Parameters.StoreName = 'Strobe';
Parameters.SyncThresh = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the strobe waveform from tank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open tank for reading
TT = tdtOpenTank('sync','Block-1');

% get all strobe data from the tank, and sort
% them based on channel
while (nRet == 1000)
    % read some records
    nRet = invoke(TT, 'ReadEventsV', 1000, Parameters.StoreName, 0,0,0,0,'NEW');

    %get data from those records we just read
    newdata = invoke(tankHandle, 'ParseEvV', 0, nRet);

    %get channels from those records we just read
    %(if chan=0, not all records will be for the same channel)
    newchan = invoke(tankHandle, 'ParseEvInfoV',0, nRet, 4);

    %add the new data to the proper cell based on channel (ch)
    for i = 1:nRet
        ch = newchan(i);
        try % if we already have data from this channel, add to it
            data{ch} = [data{ch}; newdata(:,i)];
        catch % if we dont already have data, start a new column
            data{ch} = newdata(:,i);
        end %try/catch
    end %for (i)
    
end %while

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find distributions of interspike timings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate interspike timings (the time between a spike
% in Ch. 1 and a spike in Ch. 2, not time between 2 spikes
% in a single Ch.)
% (assume that there is one reading from every cycle for each channel.
% perhaps a bad assumption? use timestamps!)
last = [0 0];
times = [];

for j = 1:min( numel(data{1}) , numel(data{2}) )
    
    if ( data{1}(j) )
        times(end + 1) = j - last(2);
        last(1) = j;
    end
    
    if ( data{2}(j) )
        times(end + 1) = j - last(1);
        last(2) = j;
    end
    
    if ( data{1}(j) && data{2}(j) )
        times(end + 1) = 0;
    end
    
end %for (j)

% find mean and standard deviation of timings
mean = mean(times);
std = std(times);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate triangle width
%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate how closely spaced spikes must be to be
% synchronous (based on Parameters.SyncThresh)
syncTime = mean + Parameters.SyncThresh * std;

% calculate actual width of triangles (based on Dawn's prospectus)
% note that all times are in cycles, not milliseconds (~25cycles = 1ms)
tWid = 3*syncTime + 25;

% set the triange width on the TDT
tdtSetTriangleWidth( tWid, 'cycles');