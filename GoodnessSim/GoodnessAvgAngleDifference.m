%% GoodnessAngleDifference
% Finds Sbest by smallest difference between movement angle and line
% between current position and target. Angles are calculated at every
% movement step and averaged over all steps in the block

% find best angles (x) and the indices where they occur(iBest)
[x iBest]=sort(Parameters.MovementErrorAngle,'ascend');

% no tie-breaking should be necessary, so just take the index with the
% lowest angle difference to be Sbest
iBest = iBest(1);