function out = psi(npred, n)

out = npred.^n ./ factorial(n) .* exp(-npred);