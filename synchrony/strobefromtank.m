close all
clear all

%% Define

% set by user
tankName = 'Crazy081307';
blockName = 'Block-2';
TankCode = 'SNIP';
stepSize = 0.001; %seconds
triangleWidth = 2*1.5*0.005; % width of triangle in seconds
T1 = 0; %start time in seconds
T2 = 60*10; %stop time in seconds

load('20080611goodchans.mat','colLookup');

MaxRet = 1000;
Channel = 0;
SortCode = 0;
Options = 'NEW';

%% Initialize

% allocate huge matrix to store data. may need to change number of columns
% here
data = zeros((T2-T1)/stepSize,24);

% make triangle
triangleSteps = triangleWidth ./ stepSize; %triangle width in time steps
if ~mod(triangleSteps, 2)
    triangleSteps = triangleSteps + 1;
end
step = 1 / (triangleSteps/2 + 0.5);
triangle = [step:step:1 (1-step):-step:step];

% open tank
tt = tdtOpenTank(tankName, blockName);


%% Get data

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
        col = colLookup(chan(n),sort(n));
        row = round(time(n)/0.001) + 1;

        data(row,col) = 1;
    end

    nRecs = invoke(tt, 'ReadEventsV', MaxRet, TankCode, Channel, SortCode, T1, T2, Options);
end

%% Finish up

tdtCloseTank(tt)
save('10minBlock2Crazy')