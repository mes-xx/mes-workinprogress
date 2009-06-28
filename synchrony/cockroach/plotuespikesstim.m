function [ fh ] = plotuespikesstim( Tau, ue, dt, spikes, ...
    sim_in,sim_out,sim_lt,sim_rt)
%PLOTSYNCSPIKESSTIM plots unitary events , spikes, and stimulus for cockroach data
%   Use this with the data you get from slidingsyncwithraster.m


t_sync = 0:Tau:Tau*length(ue)-Tau;
t_spike = 0:dt:dt*length(spikes)-dt;


fh = figure;

yshift = 0; %shift plots so that they don't overlap

plot(t_sync,ue)
hold on
yheight = max(ue);
yshift = yshift + 1.1*yheight;

plot(t_spike, spikes(:,1)*yheight + yshift)
yshift = yshift + 1.1;

plot(t_spike, spikes(:,2)*yheight + yshift)
yshift = yshift + 1.1;

x = sim_in(~isnan(sim_in));
scatter( x, yshift*ones(size(x)))
yshift = yshift + 0.1;
x = sim_lt(~isnan(sim_lt));
scatter( x, yshift*ones(size(x)))
yshift = yshift + 0.1;
x = sim_out(~isnan(sim_out));
scatter( x, yshift*ones(size(x)))
yshift = yshift + 0.1;
x = sim_rt(~isnan(sim_rt));
scatter( x, yshift*ones(size(x)))
yshift = yshift + 0.1;