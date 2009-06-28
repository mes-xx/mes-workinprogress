% This file:
%  1. Scales the referenced data
%  2. Calculates next position of cursor
%  3. Sends new position to TDT
%%%%

% apply appropriate scale factor
if (Data.Referenced.Covariance > 0)
    World.Cursor = Parameters.ScaleUp * Data.Referenced.Covariance + World.Center;
else
    World.Cursor = Parameters.ScaleDown * Data.Referenced.Covariance + World.Center;
end

% make sure the cursor is within the bounds of the world
World.Cursor = min( World.Cursor, World.Max);
World.Cursor = max( World.Cursor, World.Min);

% set target and cursor values on TDT (note that the TDT will do the
% conversion from log scale to actual frequency)
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.TargetPos'], World.Target);
invoke(TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.CursorPos'], World.Cursor);