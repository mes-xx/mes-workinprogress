World.Min = log(250); %log(Hz)
World.Max = log(16000); %log(Hz)
World.Center = log(4000); %log(Hz)


Parameters.NumberOfBlocks = 1;
Parameters.TrialsPerBlock = 1;
Parameters.TickTime = 50; %ms
Parameters.TicksPerTrial = 1000; %ticks = 50s
Parameters.TicksToHold = 6; %ticks = 540ms
Parameters.HoldMargin = 0.17 * (World.Max - World.Min); %17 percent of range (in log scale)
Parameters.SmoothingCoef = 0.5;
Parameters.BaselineTicks = 100; % = 90 seconds
Parameters.Targets = log(10000); %log(Hz)
Parameters.MaxSuccessRate = 0.5;
Parameters.TriangleWidth = 10; %ms

Parameters.Time = fix(clock);
% Parameters.Experimenter = inputdlg('Experimenter''s Name:');
% Parameters.Subject = inputdlg('Subject''s Name:');
Parameters.OutputDirectory = uigetdir;