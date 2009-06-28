% Analyzes covariance data

average = mean(covar);
stdDev = std(covar);
lows = (average - covar) > stdDev;
highs = (covar - average) > stdDev;
nlows = 0;
nhighs = 0;
for i = 1:numel(covar)
    nlows = nlows + lows(i);
    nhighs = nhighs + highs(i);
end
disp ([ int2str( numel(covar) ) ' readings total']);
disp( [ int2str( nlows ) ' lows' ] );
disp( [ int2str( nhighs ) ' highs' ] );
disp( [ 'mean = ' num2str( mean(covar), 4) ] );
