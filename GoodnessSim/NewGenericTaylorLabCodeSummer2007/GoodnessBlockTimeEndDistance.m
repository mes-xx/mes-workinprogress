%% GoodnessBlockTimeEndDistance
% Finds Sbest by shortest time to complete the block. This will be STRONGLY
% dependent on the number of repeats allowed for missed targets! Repeating
% a target adds a lot of time to the block compared to just having a hard
% time reaching a target. Uses EndDistance as a tie-breaker so in instances
% where block time is the same (which likely means that no targets were
% hit), whichever block had the cursor on average closer to the target is
% better.
% Defines iBest, the index of the best block in recent memory

% find best BlockTimes (x) and the indices where they occur(iBest)
[x iBest]=sort(Parameters.BlockTime,'ascend');

if x(1)==x(2)
% tie-breaking by end distance if necessary
    if Parameters.EndDistance(iBest(1))<Parameters.EndDistance(iBest(2))
        iBest=iBest(1);
    else
        iBest=iBest(2);
    end
else 
% if no tie-breaking needed, pick the index of best BlockTime
    iBest=iBest(1);
end