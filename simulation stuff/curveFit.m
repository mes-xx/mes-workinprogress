inputs = [vmag vx vy vz]
firingRates = 
k0 = ones(5,1);

[k, residuals, jacobian] = nlinfit(inputs, averagedata(:,1), @theCurve, k0);