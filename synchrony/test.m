% Trying to figure out why cps method depends on firing rate when Dawn says
% it shouldn't. When there is no synchrony, everything works fine (same
% level across firing rates) but when there is some synchrony, the measure
% varies with firing rates for the same amount of synchrony

% simplest triangle
triangle = [0 0.5 1 0.5 0];

spikes1 = [0 0 0 1 0 0 0 0 0 0 0 1 0 0 0];
spikes2 = [0 0 0 1 0 0 0 0 0 0 0 0 1 0 0];

t1 = conv(spikes1, triangle);
t2 = conv(spikes2, triangle);

temp = cov([t1' t2']);

sync = temp(2,1)