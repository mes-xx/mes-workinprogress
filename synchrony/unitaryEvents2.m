function [ue] = unitaryEvents2(spikes, h, Delta, Tau, S_alpha)
% unitaryEvents - Finds the number of unitary events in spike trains
% [ue, leftovers] = unitaryEvents( spikes, Delta, Tau, S_alpha) returns the unitary
% events in spikes and leftovers that should be given to the next call of
% this function. This is for use in real-time applications. Note that
% (unlike the unitaryEvents function) there is no Tau parameter. The firing
% rate is estimated and unitary events are found over the entire train. The
% entire train should be very short though (like 100 ms).
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
%   S_alpha is the level of surprise above which a synchronous event is
%   considered unitary. According to Grun et al. (2003) it should be
%   between 1.28 and 2
%
%   ue is the same size as the matrix spikes, but ue is 1 at unitary
%   events and 0 elsewhere.

T = Tau/Delta; %number of time bins in interval
b = Delta/h;

%% find firing rates

for ii = 1:2
    temp = reshape(spikes(:,ii), Tau/h, []);
    rates(:,ii) = sum(temp)/ Tau; % spikes per second
end

% bin data
temp = reshape(spikes, b, []);
binned = any(temp, 1);
v = reshape(binned, [], 2);

% find number of synchronous events

while mod(numel(v), T)
    v(end+1,:) = 0;
end

sync = v(:,1) & v(:,2);
temp = reshape(sync, T, []);
nemp =  reshape( sum(temp,1), [], 1 );

% find unitary events
npred = T.*prod(rates.*Delta,2);
%spikes/second * seconds/step

Psi = gammainc(nemp,npred,'upper');

S = log((1-Psi) ./ Psi); %surprise
 
ue = zeros(size(S));
ue(S>S_alpha) = 1;