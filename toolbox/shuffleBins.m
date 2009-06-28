function [ newSpikes ] = shuffleBins( oldSpikes, binSteps )
%SHUFFLEBINS Shuffles column vectors by changing the order of bins of data
%    newSpikes = shuffleBins( oldSpikes, binSteps )
%       newSpikes = Shuffled data
%       oldSpikes = Original data, can be a vector or a matrix of column
%                   vectors. The function shuffles each column vector
%                   independently.
%       binSteps = The number of points in each bin. In each column vector,
%                  points will be taken binSteps at a time and moved to a
%                  different place in that column vector.

% initialize variable to be returned
newSpikes = nan(size(oldSpikes));

% Figure out how many bins we have. 
nBins = floor(size(oldSpikes,1) / binSteps);
leftovers = mod( size(oldSpikes,1), nBins );

% If the original data doesn't fit evenly into bins, move the last bit of
% leftovers into the new data without shuffling it.
if leftovers > 0
    newSpikes( (end-leftovers):end, : ) = oldSpikes( (end-leftovers):end, : );
end

% Check to make sure we have at least two bins, otherwise this is pointless
if nBins < 2
    warning(['There are only ' int2str(nBins)  ' bins in shuffleBins(). Shuffling won''t actually change anything. Try using a smaller bin size or more data.'])
    newSpikes = oldSpikes;
    return
end

% for each column vector...
for col = 1:size(oldSpikes,2)
    
  % Shuffle order of bins
  newOrder = randperm(nBins);

  % Move the data to its new position
  for newBin = 1:nBins

      newRows = (1:binSteps) + (newBin-1)*binSteps;
      oldBin = newOrder(newBin);
      oldRows = (1:binSteps) + (oldBin-1)*binSteps;

      newSpikes(newRows,col) = oldSpikes(oldRows,col);
  end
end