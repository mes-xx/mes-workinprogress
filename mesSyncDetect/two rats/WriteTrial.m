% make sure output directory doesnt end in a backslash
if (Parameters.OutputDirectory(end) == '\')
    Parameters.OutputDirectory = Parameters.OutputDirectory(1:end-1);
end

% if this is the first trial in a block, then the block directory doesn't
% exist yet. we should make it.
if Trial.Number == 1
    mkdir( [Parameters.OutputDirectory '\block' int2str(Trial.BlockNumber)] );
end

filename = [Parameters.OutputDirectory '\block' int2str(Trial.BlockNumber) '\trial' int2str(Trial.Number) '.mat'];
% for the 5th trial of the 2nd block, and output directory is c:\data filename
% would be c:\data\block2\trial5.mat

save(filename, 'Trial', 'Parameters', 'SuccessRate');
% save trial, which has buffers with all covariance, rate, and cursor info.
% save parameters for info like experimenter and scale factors, and of
% course SuccessRate.