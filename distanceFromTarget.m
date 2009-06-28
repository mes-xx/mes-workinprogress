clear all

baseFilenameList = [ 'M0118R'; 'M0119R'; 'M0122R'; 'M0126R'; 'M0131R'; 'M0221R'; 'M0222R'; 'M0227R'];

for nBase = 1:size(baseFilenameList,1)
    for runCode = 2:5
        baseFilename = baseFilenameList(nBase,1:5);
        %% Load data from .cen_out file
        
        filename = ['F:\school\research\data\ballistic\' baseFilename '\' baseFilename 'R.0' num2str(runCode) '.cen_out'];

        if ~exist(filename, 'file')
            disp(['skipping ' filename])
            continue
        end

        disp(['Loading data from ' filename])

        % find data in the .cen_out file. The lines with data are between the lines
        % starting with Parameters and Comments
        fid=fopen(filename);
        collect = 0;
        data = [];
        while 1
            tline = fgetl(fid);
            if ~ischar(tline),   break,   end
            if ~isempty(findstr(tline,'Parameters'))==1
                % collect data
                while 1
                    tline = fgets(fid);
                    if ~ischar(tline),   break,   end
                    if ~isempty(findstr(tline,'Comments'))==1, break, end
                    data = [data tline];
                end
            end
        end
        fclose(fid);

        % get numbers from the data
        dataParsed = textscan(data, '%n %n %n %n %n %n %n %n %n');

        bx = dataParsed{4};
        by = dataParsed{5};
        bz = dataParsed{6};

        % turn bx by bz into unit vector
        preferredDirections = [bx by bz] ./ (sqrt(bx.^2 + by.^2 + bz.^2)*ones(1,3));

        F = dataParsed{7}; % F statistic
        firingRatesMin = dataParsed{8}; % minimum firing rate (R_min)
        firingRatesMax = dataParsed{9}; % maximum firing rate (R_max)
        N = length(bx); % number of neurons

        clear data dataParsed bx by bz

        %% Load data from .cursor file

        filename = ['F:\school\_old_\CWRU\EBME 327\project\code\' baseFilename 'R0' num2str(runCode) 'curs.mat'] ;
        disp(['Loading firing rates from ' filename])

        load( filename )

        velocity = diff(cursorPosition);
        speeds = sqrt(sum(velocity.^2,2));
        %% Discard bad data

        indices = find(speeds < .1);


        a = size(cursorPosition);

        % records which rows will be removed from teh array
        removalArray = [];

        % find consecutive indices that have speeds less than .1
        j = length(indices);
        while j > 1
            cnt = 0;
            endJ = j;
            while j>1 && indices(j)-1 == indices(j-1)
                cnt = cnt+1;
                j = j-1;
            end

            % if more than 10 rows at a time show no movement, then remove
            % those rows from the rawData
            if (cnt > 10)
                % remove rows j to endJ from the data
                if (indices(endJ) == size(targetPosition, 1))
                    cursorPosition = cursorPosition(1:indices(j), :);
                    targetPosition = targetPosition(1:indices(j), :);
                    firingRates = firingRates(1:indices(j), :);
                    brainControl = brainControl(1:indices(j), :);
                    firingRatesMean = firingRatesMean(1:indices(j), :);
                else
                    cursorPosition = [cursorPosition(1:indices(j), :); cursorPosition(indices(endJ)+1:end, :)];
                    targetPosition = [targetPosition(1:indices(j), :); targetPosition(indices(endJ)+1:end, :)];
                    firingRates = [firingRates(1:indices(j), :); firingRates(indices(endJ)+1:end, :)];
                    brainControl = [brainControl(1:indices(j), :); brainControl(indices(endJ)+1:end, :)];
                    firingRatesMean = [firingRatesMean(1:indices(j), :); firingRatesMean(indices(endJ)+1:end, :)];
                end
                % add the removed rows to the removal array (for debugging
                % purposes mainly)
                removalArray = [removalArray; j, endJ];
            end
            % move down the list of non moving indices
            j = j - 1;
        end


        distance = sqrt(sum((targetPosition - cursorPosition).^2, 2));

        % only use brain control parts
        distance = distance(brainControl == 1, :);
        targetPosition = targetPosition(brainControl == 1, :);
        firingRates = firingRates(brainControl == 1, :);
        firingRatesMean = firingRatesMean(brainControl == 1, :);

        firingRatesNormalized = 2* (firingRates - firingRatesMean) ./ (ones(size(firingRates,1), 1)*(firingRatesMax - firingRatesMin)');

        targs = [];
        for xt = [50, -50]          %
            for yt = [50, -50]      % For each target location
                for zt = [50, -50]  %
                    targs(end+1,:) = [xt, yt, zt];
                end
            end
        end

        points = struct;

        for nTarg = 1:size(targs,1)

            rows = find( all( ones(length(targetPosition),1)*targs(nTarg,:) == targetPosition, 2));

            points(nTarg).dist = distance(rows,:);
            points(nTarg).rate = firingRatesNormalized(rows,:);

            %             for nNeuron = 1:size(firingRatesNormalized,2)
            %                 scatter(points(nTarg).dist, points(nTarg).rate(:,nNeuron))
            %                 pause(0.5)
            %             end

            targUnitVector = targs(nTarg, :) / sum( targs(nTarg, :).^2, 2 );

            angles = acos( preferredDirections * targUnitVector' );

            % neurons with
            neuronsWith = find(angles < pi/2);

            % neurons against
            neuronsAgainst = find(angles >= pi/2);

            % make bins
            binsize = 5;
            for nBin = 1:200/binsize
                rows = find( (points(nTarg).dist >= (nBin-1)*binsize) & (points(nTarg).dist < (nBin)*binsize ));

                with(nTarg,nBin) = nanmean(nanmean( points(nTarg).rate(rows, neuronsWith)));
                against(nTarg,nBin) =  nanmean(nanmean( points(nTarg).rate(rows, neuronsAgainst)));
            end
            
            subplot(4,2,nTarg)
            stem(with(nTarg,:))
            hold all
            stem(against(nTarg,:))
            hold off
            title(['Target ' int2str(nTarg)])
            
        end
        save(['results' baseFilename 'R0' num2str(runCode)], 'with', 'against')
        close all
    end
end
