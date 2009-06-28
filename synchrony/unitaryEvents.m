function ue = unitaryEvents(spikes, h, Delta, Tau, S_alpha)
% unitaryEvents - Finds the number of unitary events in spike trains
% ue = unitaryEvents( spikes, Delta, Tau, S_alpha) returns the unitary
% events in spikes. 
%
%   spikes is a matrix containing two spike trains, where each row
%   represents one time step and each column represents one neuron. The
%   value is 1 at each time step where a neuron fires, and 0 elsewhere
%
%   h is the temporal resolution, or the time (in seconds) between
%   consecutive rows in the matrix spikes.
%
%   Delta is the (bin size) used to find synchronous events. When both
%   neurons spike inside a single bin, a synchronous event occurs.
%
%   Tau is the time interval (in seconds) in which the function will look
%   for unitary events. The spike train will be broken up into intervals of
%   length Tau and the number of synchronous events counted. The firing
%   rates will be estimated across 20*Tau.
%
%   S_alpha is the level of surprise above which a synchronous event is
%   considered unitary. According to Grun et al. (2003) it should be
%   between 1.28 and 2
%
%   ue is the same size as the matrix spikes, but ue is 1 at unitary
%   events and 0 elsewhere.

T = Tau/Delta; %number of time bins in interval
b = Delta/h; %(seconds/bin) / (seconds/step) = steps/bin

%% find firing rates

avgspikes = runmean(spikes, floor(10*Tau/h));
%average number of spikes over a window of size 20*T + 1

rates = avgspikes ./ h; %convert spikes/step to spikes/second
rates = resample(rates, 1, Tau/h);


% for some reason, sometimes the firing rates turn out to be small negative
% numbers, which will cause an error later. So, here I will just set all
% those rates to 0.
rates(rates<0) = 0;

% this makes sure that spikes  is 
while mod(size(spikes,1), b)
    spikes(end+1,:) = 0;
end

% bin data
temp = reshape(spikes, b, []); % each col is one bin (of length Delta) each row is one timestep inside that bin
binned = any(temp, 1); % puts a 1 when there is at least one spike in that bin. the result is a vector where each element is one bin.
v = reshape(binned, [], 2); % rearrange binned so that we have two neurons again instead of one giant long vector

%% find number of synchronous events

while mod(size(v,1), T)
    v(end+1,:) = 0;
end

sync = v(:,1) & v(:,2); % if both neurons spike in a given bin, then there is a synchronous event there
temp = reshape(sync, T, []);
nemp =  reshape( sum(temp,1), [], 1 );

% find unitary events
npred = T.*prod(rates.*Delta,2);
%spikes/second * seconds/step


Psi = gammainc(nemp,npred,'upper');

S = log((1-Psi) ./ Psi); %surprise

ue = zeros(size(S));
ue(S>S_alpha) = 1;