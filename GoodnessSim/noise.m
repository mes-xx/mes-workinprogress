%% intitialize correlation matrix
% ones on the main diagonal because each signal is (of course) perfectly correlated with itself
noise_correlation = eye(TDT.num_chan);

%% generate random correlations, diagonal by diagonal
% must do one diagonal at a time to maintain symmetry across main diagonal
for d = 1:(TDT.num_chan - 1)
    
    % generate the diagonal of proper length
    % also, the correlations should be between -1 and 1, but rand() gives
    % numbers between 0 and 1
    corrs = 2 * rand(1, TDT.num_chan - d) - 1;
    
    % now put add those corrleations (on the proper diagonals above and
    % below the main diagonal) to the correlation matrix
    noise_correlation = noise_correlation ...
        + diag(corrs, d) ...
        + diag(corrs, -d);
    
end

% every time we want some random, correlated noise, we do:
samples = 1; %number of samples of noise we want
noise = copularnd('Gaussian', noise_correlation, samples);