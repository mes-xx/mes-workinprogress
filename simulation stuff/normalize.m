function y = normalize(x)
% Normalizes vectors. Treats a matrix like a series of row vectors.

magnitude = sqrt(sum(x.^2,2)) * ones(1, size(x,2));

y = x ./ magnitude;
