% Reads data from TDT tank and makes it into a strobe signal. Saves this
% signal for later processing.

% adjust these parameters
tank = 'tdtReplay' %name of tank
store = 'EAxx' %name of store with snippet data

% open tdt tank
tt = tdtOpenTank(tank);

% make a list of blocks
blockList = tdtListBlocks(tt);

% for each block...
for n = 2 %1:numel(blockList)
    block = blockList{n}

    % select this block
    if ( invoke(tt, 'SelectBlock', block) ~= 1 )
        warning('Could not select block.')
    end

    % make strobe
    strobe = snip2strobe(tt,'EAxx');

    % save strobe for later
    save(sprintf('%s_strobe.mat',block), 'strobe')
end

% clean up
tdtCloseTank(tt)