clear all;

% path and file name of parameters files
filename = 'TST07010701params\Parameters';

% how many blocks
numBlocks = 100;

% how many blocks are remembered in parameters files
bufSize = 3; 

% declare all the variables
    NBlocksPerUpdate = [];
    NumTriesPerTarg = [];
    MaintainPercentHit = [];
    MinBlocksBeforeBreak = [];
    NumBlocksHeld = [];
    mean_windowbyTarg = [];
    std2power = [];
    meanpower = [];
    MeanPowerByTarget = [];
    estNpower = [];
    numBlocksRun = [];
    Wp = [];
    Wn = [];
    Ca1 = [];
    Ca2 = [];
    Amax = [];
    Cb = [];
    NumBlocksEarlyLimit = [];
    Phit = [];
    BlockTime = [];
    EndDistance = [];
    Mag = [];
    TargetRad = [];
    Drift = [];
    RadAdjust = [];

% loop through all blocks
for n = 1:numBlocks
    % load parameters for current block
    load([filename num2str(n)]);
    
    % where the current block data is in the buffer from the data file 
    bufIndex = mod(n,bufSize);
   
    % no 0th index in matlab
    if bufIndex == 0
        bufIndex = 3;
    end
    
    %extract all data from the current block
    NBlocksPerUpdate(n) = Parameters.NBlocksPerUpdate;
    NumTriesPerTarg(n) = Parameters.NumTriesPerTarg;
    MaintainPercentHit(n) = Parameters.MaintainPercentHit;
    MinBlocksBeforeBreak(n) = Parameters.MinBlocksBeforeBreak;
    NumBlocksHeld(n) = Parameters.NumBlocksHeld;
    mean_windowbyTarg(n) = Parameters.mean_windowbyTarg;
    std2power(:,n) = Parameters.std2power;
    meanpower(:,n) = Parameters.meanpower;
    MeanPowerByTarget(:,:,n) = Parameters.MeanPowerByTarget;
    estNpower(:,n) = Parameters.estNpower;
    numBlocksRun(n) = Parameters.numBlocksRun;
    Wp(:,:,n) = Parameters.Wp(:,:,bufIndex);
    Wn(:,:,n) = Parameters.Wn(:,:,bufIndex);
    Ca1 = Parameters.Ca1;
    Ca2 = Parameters.Ca2;
    Amax = Parameters.Amax;
    Cb = Parameters.Cb;
    NumBlocksEarlyLimit = Parameters.NumBlocksEarlyLimit;
    Phit(n) = Parameters.Phit(bufIndex);
    BlockTime(n) = Parameters.BlockTime(bufIndex);
    EndDistance = Parameters.EndDistance(bufIndex);
    Mag(:,n) = Parameters.Mag(bufIndex,:);
    TargetRad = Parameters.TargetRad;
    Drift(:,n) = Parameters.Drift;
    
    % this variable wasnt defined in first block
    if n > 1
        RadAdjust = Parameters.RadAdjust;
    end
    
end

clear Parameters;