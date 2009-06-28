numBlocks = 50;
bufSize = 3;

paths = {};

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
    
    EndDistanceMax = [];
    MeanA = [];
    MovementErrorAngle = [];
    PositionErrorAngle = [];
    EndPositionErrorAngle = [];
    StableBlocks = [];
    ErrorMagnitude = [];
    ErrorConsistency = [];

for x = 1017:1136
    number = num2str(x);
    number = number(2:4);
    
    paths{end+1} = ['F:\school\research\data\GoodnessSim\GS041608\GS041608' number 'params\Parameters'];
end

for nFile = 1:numel(paths)

filename = paths{nFile};




for n = 1:numBlocks
    load([filename num2str(n)]);
    
    bufIndex = mod(n,bufSize);
   
    if bufIndex == 0
        bufIndex = 3;
    end
    
    NBlocksPerUpdate(nFile) = Parameters.NBlocksPerUpdate;
    NumTriesPerTarg(nFile,n) = Parameters.NumTriesPerTarg;
    MaintainPercentHit(nFile,n) = Parameters.MaintainPercentHit;
    MinBlocksBeforeBreak(nFile,n) = Parameters.MinBlocksBeforeBreak;
    NumBlocksHeld(nFile,n) = Parameters.NumBlocksHeld;
    mean_windowbyTarg(nFile,n) = Parameters.mean_windowbyTarg;
    std2power(nFile,:,n) = Parameters.std2power;
    meanpower(nFile,:,n) = Parameters.meanpower;
    MeanPowerByTarget(nFile,:,:,n) = Parameters.MeanPowerByTarget;
    estNpower(nFile,:,n) = Parameters.estNpower;
%    numBlocksRun(n) = Parameters.numBlocksRun;
    Wp(nFile,:,:,n) = Parameters.Wp(:,:,bufIndex);
    Wn(nFile,:,:,n) = Parameters.Wn(:,:,bufIndex);
    Ca1(nFile) = Parameters.Ca1;
    Ca2(nFile) = Parameters.Ca2;
    Amax(nFile) = Parameters.Amax;
    Cb(nFile) = Parameters.Cb;
    NumBlocksEarlyLimit(nFile) = Parameters.NumBlocksEarlyLimit;
    Phit(nFile,n) = Parameters.Phit(bufIndex);
    BlockTime(nFile,n) = Parameters.BlockTime(bufIndex);
    EndDistance(nFile,n) = Parameters.EndDistance(bufIndex);
    
    EndDistanceMax(nFile,n) = Parameters.EndDistanceMax(bufIndex);
    MeanA(nFile,n) = Parameters.MeanA(bufIndex);
    MovementErrorAngle(nFile,n) = Parameters.MovementErrorAngle(bufIndex);
    PositionErrorAngle(nFile,n) = Parameters.PositionErrorAngle(bufIndex);
    EndPositionErrorAngle(nFile,n) = Parameters.EndPositionErrorAngle(bufIndex);
    StableBlocks(nFile,n) = Parameters.StableBlocks;
    ErrorMagnitude(nFile,n) = Parameters.ErrorMagnitude;
    ErrorConsistency(nFile,n) = Parameters.ErrorConsistency;
    
    Mag(nFile,:,n) = Parameters.Mag(bufIndex,:);
    TargetRad(nFile,n) = Parameters.TargetRad;
    Drift(nFile,:,n) = Parameters.Drift;
    
    if n > 1
        RadAdjust(nFile,n) = Parameters.RadAdjust;
    end
    
end
end