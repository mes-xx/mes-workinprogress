function [ blist ] = tdtListBlocks( tt, ind )
%TDTLISTBLOCKS Lists names blocks in TDT tank
%
% blist = tdtListBlocks(tt,ind)
% Returns a cell array of block names (blist) from a TDT tank that is open
% using TTankX. The tank handle (tt) can be created using the tdtOpenTank
% function. Optional parameter (ind) gives a list of the indices of the
% blocks to list. If this is omitted, a list of all blocks is returned

blist = {};

if nargin == 2 % if ind was provided
    for n = ind % for each index provided
        blockName = invoke(tt,'QueryBlockName',n); %get the name of this block
        blist{end+1} = blockName; %add this name to the list
    end
    return % we are done!
end

% the default behavior starts here. if ind is not given, then start at
% index 1 and keep going until we run out of blocks
n = 1;
blockName = invoke(tt,'QueryBlockName',n);
while ~strcmp(blockName,'') %while we have blocks
    % add the last block's name to the list
    blist{end+1} = blockName;
    
    %try to get the name of the next block
    n=n+1;%increment block  index
    blockName = invoke(tt,'QueryBlockName',n);
    % if there are no more blocks at this point, then blockName will be an
    % empty string and the while loop will exit. The empty string will not
    % be added to the list of blocks.
end