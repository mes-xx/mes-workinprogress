%% GoodnessPhitBlockTime
% Finds Sbest by highest Phit, using BlockTime as a tie-breaker.
% Defines iBest, the index of the best block in recent memory

% find best Phits (x) and the indices where they occur(iBest)
[x iBest]=sort(Parameters.Phit,'descend');

if x(1)==x(2)
% tie-breaking by block time if necessary
    if Parameters.BlockTime(iBest(1))<Parameters.BlockTime(iBest(2))
        iBest=iBest(1);
    else
        iBest=iBest(2);
    end
else 
% if no tie-breaking needed, pick the index of best Phit
    iBest=iBest(1);
end