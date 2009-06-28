function strobe = snip2strobe( tt, store )
% snip2strobe makes spike trains from data in TDT tank
%
% strobe = snip2strobe(tt, store) -- Reads snippet data from a TTank
% ActiveX control (tt) and creates a strobe signal for each channel (for
% now it ignores sort codes). The strobe signal is 1 at one timestep at the
% beginning of each spike and zero elsewere. The data store must be from an
% oxSnippet header that contains the spike waveforms from a SortSpike
% control. This function uses the timestamps on the snippets to make the
% strobe signal.

time = [];
chan = [];
% start by reading in some events from the tank
n = invoke(tt, 'ReadEventsV', 1000, store, 0, 0, 0, 0, 'NEW');

% while we have more events...
while n > 0
    
    % get timestamp and channel number for the records.
    % There is one timestamp for the beginning of each spike, so our strobe
    % will fire (for the given channel) at each timestamp
    time = [time invoke(tt, 'ParseEvInfoV', 0, n, 6)];
    chan = [chan invoke(tt, 'ParseEvInfoV', 0, n, 4)];
    
    
    % try to read more events. if we are out of events to read, n will be
    % 0, and we will exit the loop.
    n = invoke(tt, 'ReadEventsV', 1000, store, 0, 0, 0, 0, 'NEW');
    
end %while

% now we have all time stamps. convert them all into indices in my strobe
% array. Let each index in the strobe array represent one time step on the
% TDT (assume sample freq = 24414.0625 cycles/second)
indices = round(time.* 24414.0625);

% initialize the strobe signal as all zeros
rows = max(max(indices)); % this is how many time steps we need (last spike will be on last time step)
cols = max(max(chan)); % this is how many channels we have
strobe = zeros(rows,cols);
try
% loop through the channels inserting the spikes for each into strobe
for ch = 1:cols
    
    % select the timestamps that belong to this channel
    sel = chan == ch;
    
    % insert selected spikes at the proper indices and channel
    strobe( indices(sel), ch ) = 1;
end
catch
    keyboard
end