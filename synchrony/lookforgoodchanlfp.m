% Plot the first 10 minutes from every LFP channel

colLookup = [];
data = [];


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

    newd = invoke(tt, 'ParseEvV', RecIndex, nRecs);

    data = [data newd];

    nRecs = invoke(tt, 'ReadEventsV', MaxRet, TankCode, Channel, SortCode, T1, T2, Options);
end % repeat for one minute of data

tdtCloseTank(tt)

keyboard

% downsample
old_dt = (T2-T1)/size(data,2);
new_dt = 0.09;
decfactor = round(new_dt/old_dt);
datadec = [];
for startcol = 1:decfactor:size(data,2)
    endcol = min(startcol + decfactor - 1, size(data,2));
    datadec = [datadec mean(data(:,startcol:endcol),2)];
end
    

% plot all data
% for ii = 1:size(data,2)
%     figure
%     plot(data(:,ii))
%     title(['Channel ' num2str(ii)])
% end
%    

