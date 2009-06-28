% This file runs everything.

clear all;

% Ask the user where to get preferences from
[filename pathname] = uigetfile('*.m');

% chop file extension (should be .m) from filename
dotPosition = findstr('.', filename);
dotPosition = dotPosition(end); 
filename = filename(1:dotPosition-1);

% run the config file
oldDirectory = pwd;
cd(pathname);
eval(filename);
cd(oldDirectory);
 

InitializeExperiment;

for n = 1:Parameters.NumberOfBlocks
      
    RunTrials;
    UpdateWeights;
    
end

Close_ActX;