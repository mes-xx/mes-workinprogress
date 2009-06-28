%plot phit and ps over time

filename = 'F:\school\research\data\GoodnessSim\GS032408\GS032408025params\Parameters';
numBlocks = 40;
bufSize = 3;

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

for n = 1:numBlocks
    load([filename num2str(n)]);
    
    bufIndex = mod(n,bufSize);
   
    if bufIndex == 0
        bufIndex = 3;
    end
    
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
%    numBlocksRun(n) = Parameters.numBlocksRun;
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
    TargetRad(n) = Parameters.TargetRad;
    Drift(:,n) = Parameters.Drift;
    
    if n > 1
        RadAdjust = Parameters.RadAdjust;
    end
    
end