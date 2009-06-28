% only change weights if subject's success rate is greater than the maximum
if (SuccessRate > Parameters.MaxSuccessRate)
    
    % reduce hold margin by 10 percent
    Parameters.HoldMargin = 0.9 .* Parameters.HoldMargin;
    
end
    