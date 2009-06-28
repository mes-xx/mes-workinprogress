% Figure out how we retreive data from tank

colLookup = [];
chan = [];
time = [];


% open tank
tt = tdtOpenTank('Crazy081307', 'Block-2');

% get data
MaxRet = 1000; %maximum number of events to return at one time
TankCode = 'LFPx'; %name of event
Channel = 0; %channel number, or 0 for all channels
SortCode = 0; %sort code, or 0 for all sort codes
T1 = 0; %start time
T2 = 60*10; %end time
Options = 'NEW';
nRecs = invoke(tt, 'ReadEventsV', MaxRet, TankCode, Channel, SortCode, T1, T2, Options);

while nRecs > 0
    
    RecIndex = 0; %starting index

    %newd = invoke(tt, 'ParseEvV', RecIndex, nRecs);
    nItem = 6;
    newtime = invoke(tt, 'ParseEvInfoV', RecIndex, nRecs, nItem);
%     nItem = 4;
%     newchan = invoke(tt, 'ParseEvInfoV', RecIndex, nRecs, nItem);

%    chan = [chan newchan];
    time = [time newtime];

    nRecs = invoke(tt, 'ReadEventsV', MaxRet, TankCode, Channel, SortCode, T1, T2, Options);
end % repeat for one minute of data

tdtCloseTank(tt)

keyboard

% plot all data
for ii = 1:size(data,2)
    figure
    plot(data(:,ii))
    title(['Channel ' num2str(ii)])
end
    