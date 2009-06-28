clear all
close all

figure(1)

%% (a) spike trains

rates = [20 20];
stepSize = 0.001;
offset = 0.003;
binSize = 0.1;

trainLength = 0.2; %seconds
nSync  = min(rates)*trainLength; % all spikes are synchronous
spikes = makeSpikeTrains3(rates, nSync, trainLength, stepSize, offset );

trainLength = 0.1; %seconds
nSync = 0; %spikes
rates = [40 40];
temp = makeSpikeTrains3(rates, nSync, trainLength, stepSize, offset );

spikes = [spikes; temp];

% get spikes as indivdual points for scatter plotting
time = 1:size(spikes,1); %should be 300 time steps
spikepts1 = find(spikes(:,1));
spikepts2 = find(spikes(:,2));
bins = 0:100:length(time);

subplot(2,2,1)
plot( 1*ones(size(time)), '--' ) % dotted line to mark first spike train
hold on
plot( 4*ones(size(time)), '--' ) % dotted line to mark second spike train
scatter(spikepts1, 1*ones(size(spikepts1))) % spikes in first train
scatter(spikepts2, 4*ones(size(spikepts2))) % spikes in second train
scatter(bins,zeros(size(bins))) % lines to divide analysis windows
axis([0 length(time) -1 6])

%% (b) triangly waveform

% make the triangle
triangleSteps = 20;
if ~mod(triangleSteps, 2) % Make sure that the triangle has an odd number of steps
    triangleSteps = triangleSteps + 1;
end
step = 1 / (triangleSteps/2 + 0.5);
triangle = [step:step:1 (1-step):-step:step];

% convolve to make the triangly waveform
for n = 1:size(spikes,2)
    twave(:,n) = conv( spikes(:,n), triangle );
end

% shift the wave so that it looks like triangles are centered on spikes,
% instead of beginning at spikes
twave = twave( ceil(triangleSteps/2):end, : );

% duplicate the plot from part (a), but overlay the triangly waveform
subplot(2,2,2)
plot( 1*ones(size(time)), '--' ) % dotted line to mark first spike train
hold on
plot( 4*ones(size(time)), '--' ) % dotted line to mark second spike train
scatter(spikepts1, 1*ones(size(spikepts1))) % spikes in first train
scatter(spikepts2, 4*ones(size(spikepts2))) % spikes in second train
scatter(bins,zeros(size(bins))) % lines to divide analysis windows
axis([0 length(time) -1 6])

plot(twave(:,1)+1)
plot(twave(:,2)+4)

%% (c) subtract means

% subtract means from twave over each analysis window
for nWindow = 1:3
    iStart = (nWindow-1)*100 + 1;
    iEnd = nWindow*100;
    avg = mean(twave(iStart:iEnd,:));
    twave(iStart:iEnd,:) = twave(iStart:iEnd,:) - ones((iEnd-iStart)+1,1)*avg;
end

% plot new twaves, as in part (b)
subplot(2,2,3)
plot( 1*ones(size(time)), '--' ) % dotted line to mark first spike train
hold on
plot( 4*ones(size(time)), '--' ) % dotted line to mark second spike train
scatter(spikepts1, 1*ones(size(spikepts1))) % spikes in first train
scatter(spikepts2, 4*ones(size(spikepts2))) % spikes in second train
scatter(bins,zeros(size(bins))) % lines to divide analysis windows
axis([0 length(time) -1 6])

plot(twave(:,1)+1)
plot(twave(:,2)+4)

%% (d) take covariance

sync = [];
for nWindow = 1:3
    iStart = (nWindow-1)*100 + 1;
    iEnd = nWindow*100;
    temp = cov(twave(iStart:iEnd,:));
    sync(iStart:iEnd) = temp(1,2);
end

% plot new twaves, as in part (b)
subplot(2,2,4)
hold on
plot(sync*10)
scatter(bins,zeros(size(bins))) % lines to divide analysis windows
xlim([0 length(time)])