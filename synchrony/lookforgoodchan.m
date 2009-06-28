% Plot the first minute from every channel/sort code combination in the
% tank to manually pick the best ones

colLookup = [];
data = [];


% open tank
tt = tdtOpenTank('Crazy081307', 'Block-2');

% get data
MaxRet = 1000; %maximum number of events to return at one time
TankCode = 'SNIP'; %name of event
Channel = 0; %channel number, or 0 for all channels
SortCode = 0; %sort code, or 0 for all sort codes
T1 = 0; %start time
T2 = 60; %end time
Options = 'NEW';
nRecs = invoke(tt, 'ReadEventsV', MaxRet, TankCode, Channel, SortCode, T1, T2, Options);

while nRecs > 0
    
    RecIndex = 0; %starting index

    nItem = 6;
    time = invoke(tt, 'ParseEvInfoV', RecIndex, nRecs, nItem);
    nItem = 4;
    chan = invoke(tt, 'ParseEvInfoV', RecIndex, nRecs, nItem);
    nItem = 5;
    sort = invoke(tt, 'ParseEvInfoV', RecIndex, nRecs, nItem) + 1;

    % separate by channel and sort code
    for n = 1:nRecs
        try
            col = colLookup(chan(n),sort(n));
        catch
            col = size(data, 2) + 1;
            colLookup(chan(n),sort(n)) = col;
        end
        
        if col < 1
            col = size(data, 2) + 1;
            colLookup(chan(n),sort(n)) = col;
        end            
        
        row = round(time(n)/0.001) + 1;
        
        data(row,col) = 1;
        
    end
    nRecs = invoke(tt, 'ReadEventsV', MaxRet, TankCode, Channel, SortCode, T1, T2, Options);
end % repeat for one minute of data

tdtCloseTank(tt)

% plot all data
for ii = 1:size(data,2)
    figure
    plot(data(:,ii))
    [chan sort] = find(colLookup==ii);
    sort = sort-1;
    title(['Channel ' num2str(chan) ' sort ' num2str(sort)])
end
    