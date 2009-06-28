% only change weights if subject's success rate is greater than the maximum
if (SuccessRate > Parameters.MaxSuccessRate)
    
    % reduce scale factors by 10 percent
    Parameters.ScaleUp = 0.9 * Parameters.ScaleUp;
    Parameters.ScaleDown = 0.9 * Parameters.ScaleDown;
end
    