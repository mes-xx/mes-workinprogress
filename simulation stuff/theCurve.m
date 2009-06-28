function firingRate = theCurve( k, inputs )

vmag = inputs(:,1);
vx   = inputs(:,2);
vy   = inputs(:,3);
vz   = inputs(:,4);

b0 = k(1); 
bn = k(2);
bx = k(3);
by = k(4);
bz = k(5);

firingRate = b0 + vmag.*( bn + bx*vx + by*vy + bz*vz );