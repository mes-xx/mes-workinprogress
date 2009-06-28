%% GoodnessPhitEndDistance
% Finds Sbest by highest Phit, using EndDistance as a tie-breaker.
% Defines iBest, the index of the best block in recent memory

% find best Phits (x) and the indices where they occur(iBest)
[x iBest]=sort(Parameters.Phit,'descend');

if x(1)==x(2)
% tie-breaking by end distance if necessary
    if Parameters.EndDistance(iBest(1))<Parameters.EndDistance(iBest(2))
        iBest=iBest(1);
    else
        iBest=iBest(2);
    end
else 
% if no tie-breaking needed, pick the index of best Phit
    iBest=iBest(1);
end