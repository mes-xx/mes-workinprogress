% must begin with Phit of size (number of blocks) x (number of repeats)

%%

% now, arrange Phits into contiguous groups for analysis. each row
% represents one "group" and each number in that row is a column number
% from Phit that belongs in that group

% give names to the groups
groupNames = { 'GoodnessAvgAngleDifference' ...
    'GoodnessAvgEndDistance' 'GoodnessBlockTimeEndDistance' ...
    'GoodnessEndingAngleDifference' 'GoodnessMaxEndDistance' ...
    'GoodnessMeanA' 'GoodnessPhitBlockTime' 'GoodnessPhitEndDistance'};

nGroups = length(groupNames);

for n = 1:nGroups
    groups(n,:) = (0:89)*8 + n;
end


% for each threshold level...
for thresh = 0.8

    % find threshold crossings and wiggle after crossings
    for trial = 1:size(Phit,2)
        try
            timeToConverge(trial) = find(Phit(:,trial) >= thresh, 1, 'first');
        catch
            timeToConverge(trial) = size(Phit,1);
        end
        wiggle(trial) = var(Phit(timeToConverge(trial):end,trial));
    end
    
    % average timeToConverge and wiggle over groups
    for n = 1:nGroups
        timeToConvergeByGroup(n) = mean( timeToConverge(:,groups(n,:)), 2 );
        timeToConvergeByGroupStd(n) = std( timeToConverge(:,groups(n,:)), 1,2 );
        wiggleByGroup(n) = mean( wiggle(:,groups(n,:)), 2 );
        wiggleByGroupStd(n) = std( wiggle(:,groups(n,:)), 1,2);
    end
    
    % do a ttest to see if timesToConverge and wiggles are different in
    % different groups
    for x = 1:nGroups
        for y = x+1:nGroups
            [h,p] = ttest2(timeToConverge(groups(x,:)), timeToConverge(groups(y,:)));
            if (h)
                disp(['Different time to converge: ' num2str(x) ' and ' num2str(y) ' for thresh = ' num2str(thresh)])
            end
        end
    end
    
    for x = 1:nGroups
        for y = x+1:nGroups
            [h,p] = ttest2(wiggle(groups(x,:)), wiggle(groups(y,:)));
            if (h)
                disp(['Different wiggle: ' num2str(x) ' and ' num2str(y) ' for thresh = ' num2str(thresh)])
            end
        end
    end
end

        
%% Graph some results

figure
bar(timeToConvergeByGroup)
hold all
errorbar(timeToConvergeByGroup, timeToConvergeByGroupStd, '.')
title('Time to converge')
xlabel('Measure of performance')
ylabel('Number of blocks')

figure
bar(wiggleByGroup)
hold all
errorbar(wiggleByGroup, wiggleByGroupStd, '.')
title('Variance in performance after convergence')
xlabel('Measure of performance')
ylabel('Variance')