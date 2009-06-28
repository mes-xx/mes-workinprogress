function [ fh ] = plotsyncspike (n1, n2, t_sync, syncs, ...
    significant_high ,significant_low, t_spike, spikes )
%PLOTSYNCSPIKESSTIM plots synchrony, spikes, and stimulus for cockroach data
%   Use this with the data you get from slidingsyncwithraster.m

fh = figure;

yshift = 0; %shift plots so that they don't overlap

y = squeeze(syncs(n1,n2,:));
plot(t_sync,y)
hold on
plot(t_sync,significant_high(n1,n2)*ones(size(t_sync)))
plot(t_sync,significant_low(n1,n2)*ones(size(t_sync)))
yheight = max(y);
yshift = yshift + 1.1*yheight;

plot(t_spike, spikes(:,n1)*yheight + yshift)
yshift = yshift + 1.1*yheight;

plot(t_spike, spikes(:,n2)*yheight + yshift)
yshift = yshift + 1.1*yheight;