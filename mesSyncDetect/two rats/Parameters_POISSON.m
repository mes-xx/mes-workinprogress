World.Min = log(250); %log(Hz)
World.Max = log(16000); %log(Hz)
World.Center = log(4000); %log(Hz)


Parameters.NumberOfBlocks = 1;
Parameters.TrialsPerBlock = 10;
Parameters.TickTime = 180; %ms
Parameters.TicksPerTrial = 500; %ticks = 90s
Parameters.TicksToHold = 5; %ticks = 540ms
Parameters.HoldMargin = 0.17 * (World.Max - World.Min); %17 percent of range (in log scale)
Parameters.SmoothingCoef = 0.5;
Parameters.BaselineTicks = 100; % = 90 seconds
Parameters.Targets = log(10000); %log(Hz)
Parameters.MaxSuccessRate = 0.5;
Parameters.TriangleWidth = 10; %ms

Parameters.Time = fix(clock);
Parameters.Experimenter = inputdlg('Experimenter''s Name:');
Parameters.Subject = inputdlg('Subject''s Name:');
Parameters.OutputDirectory = uigetdir;

Parameters.NumberOfChannels = 6;

%Parameters.aSNIP = {1 2 3 4 5 6 7 8 9 10 11 12}; % optionally provide thresholds for sort spike (all 12 channels)
%Parameters.cSNIP = {1 2 3 4 5 6 7 8 9 10 11 12}; % optionally provide coefs for sort spike (all 12 channels
Parameters.SortCodes = {1 1 1 1 1 1}; % sort codes to use from each channel
Parameters.Channels = {1 2 3 4 5 6}; % channels to read
Parameters.RefChan = 1; % reference channel number
Parameters.RefEnable = 0; % enable reference (set to -1 for yes or 0 for no)
%Parameters.HPSpike = 300; % high-pass filter frequency
%Parameters.LPSpike = 3000; % low-pass filter frequency

Parameters.ParTagSuffix = '1'; %added to the end of most ParTags so that two instances of MATLAB can be running and reading two different sets of data
Parameters.MyRates = 1:6; % rates that belong to this subject
Parameters.MyCovariances = 1;