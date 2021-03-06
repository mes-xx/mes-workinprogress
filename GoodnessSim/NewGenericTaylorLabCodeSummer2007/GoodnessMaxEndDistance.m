%% GoodnessMaxEndDistance
% Finds Sbest by lowest of the maximum ending distances from the target. No
% tie-breaker necessary. Even when all targets are hit, EndDistance != 0
% because top get a hit, the cursor does not need to be exactly on top of
% the target, so a block with smaller radius with 1.00 Phit will have a
% lower EndDistance.
% Defines iBest, the index of the best block in recent memory

% find best ending distances (x) and the indices where they occur(iBest)
[x iBest]=sort(Parameters.EndDistanceMax,'ascend');

% no tie-breaking should be necessary, so just take the index with the
% lowest MaxEndDistance to be Sbest
iBest = iBest(1);