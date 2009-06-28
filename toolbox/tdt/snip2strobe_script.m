%function strobe = snip2strobe( tt, store )
% makeStrobe(tt, store) - Reads snippet data from a TTank ActiveX control 
% (tt) and creates a strobe signal for each channel (for now it ignores 
% sort codes)

tt = tdtOpenTank('Crazy081307','Block-2');
store = 'SNIP';

resolution = 0.0005 %seconds/sample
nSamples = 500e3

nChan = 24;
nSort = 3;

T1 = 0 %seconds
T2 = T1 + nSamples * resolution %samples * seconds/sample = seconds

dimStrobe = [nSamples, nChan*nSort];
strobe = zeros( dimStrobe );


% start by reading in some events from the tank
n = invoke(tt, 'ReadEventsV', 1000, store, 0, 0, T1, T2, 'NEW');

% while we have more events...
while n > 0
    
    % get timestamp and channel number for the records.
    % There is one timestamp for the beginning of each spike, so our strobe
    % will fire (for the given channel) at each timestamp
    time = invoke(tt, 'ParseEvInfoV', 0, n, 6);
    chan = invoke(tt, 'ParseEvInfoV', 0, n, 4);
    sort = invoke(tt, 'ParseEvInfoV', 0, n, 5);
    
    row = round(time / resolution);
    col = (chan-1)*nSort + (sort+1);
    
    indices = sub2ind(dimStrobe, row, col);
    
    strobe(indices) = 1;
    
    % try to read more events. if we are out of events to read, n will be
    % 0, and we will exit the loop.
    n = invoke(tt, 'ReadEventsV', 1000, store, 0, 0, T1, T2, 'NEW');
    
end %while

tdtCloseTank(tt)