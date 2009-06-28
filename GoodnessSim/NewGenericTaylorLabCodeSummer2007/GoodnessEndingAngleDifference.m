%% GoodnessEndPositionErrorAngle
% Finds Sbest by smallest angle difference between the lines from movement
% area center through the current position and from movement area center
% through the target position at the end of each trial

% find best angles (x) and the indices where they occur(iBest)
[x iBest]=sort(Parameters.EndPositionErrorAngle, 'ascend');

% no tie-breaking should be necessary, so just take the index with the
% lowest angle difference to be Sbest
iBest = iBest(1);