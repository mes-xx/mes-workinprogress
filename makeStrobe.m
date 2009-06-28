function strobe = makeStrobe( tt, store )
% makeStrobe(tt, store) - Reads snippet data from a TTank ActiveX control 
% (tt) and creates a strobe signal for each channel (for now it ignores 
% sort codes)

strobe = [];

% start by reading in some events from the tank
n = invoke(tt, 'ReadEventsV', 100, store, 0, 0, 0, 0, 'NEW');

% while we have more events...
while n > 0
    
    % get timestamp and channel number for the records.
    % There is one timestamp for the beginning of each spike, so our strobe
    % will fire (for the given channel) at each timestamp
    time = invoke(tt, 'ParseEvInfoV', 0, n, 6);
    chan = invoke(tt, 'ParseEvInfoV', 0, n, 4);
    
    for x=1:numel(time)
        
        % convert timestamp to sample cycle number (assume sample frequency
        % is 24414.0625 cycles / second)
        index = round(time(x) .* 24414.0625);
        
        % in the strobe matrix, there is one row for every sample cycle and
        % one column for every channel (in order)
        strobe(index, chan(x)) = 1;
        
    end
    
    % try to read more events. if we are out of events to read, n will be
    % 0, and we will exit the loop.
    n = invoke(tt, 'ReadEventsV', 100, store, 0, 0, 0, 0, 'NEW');
    
end