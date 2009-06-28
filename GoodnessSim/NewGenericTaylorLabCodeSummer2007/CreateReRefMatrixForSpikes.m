function CreateReRefMatrixForSpikes(units, filename, numElectrodes, numBins)

% CreateReRefMatrixForSpikes creates a rereference matrix for spike
% sorting.
% units - a 2 column array whose coordinates (Bin, Electrode) specify which
%		  units should be used for decoding.
% filename - filename for the rereference matrix file
% numElectrodes - number of electrodes in the TDT project
% numBins - number of sorting bins per electrode
%


reref = zeros(numBins, numElectrodes);
for i = 1 : size(units, 1)
	reref(units(i, 1), units(i, 2)) = 1;
end

reref

dlmwrite(filename, reref, '\t');









