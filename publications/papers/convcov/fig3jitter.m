close all
clear all

% %% different conv shapes
% figure(31)
% 
% % square
% shapes.square = [zeros(1,1e4) ones(1,5e4) zeros(1,1e4)];
% subplot(3,2,1)
% plot(shapes.square)
% axis tight
% temp = ylim;
% ylim(1.2*temp);
% title('Square')
% % gaussian
% shapes.gaussian = normpdf(-5:0.01:5,0,1);
% subplot(3,2,2)
% plot(shapes.gaussian)
% axis tight
% temp = ylim;
% ylim(1.2*temp);
% title('Gaussian')
% % triangle
% shapes.triangle = [linspace(0,1,100) linspace(1,0,100)];
% subplot(3,2,3)
% plot(shapes.triangle)
% axis tight
% temp = ylim;
% ylim(1.2*temp);
% title('Triangle')
% % sinc
% shapes.sinc = sinc(-pi/2:0.01:pi/2);
% subplot(3,2,4)
% plot(shapes.sinc)
% axis tight
% temp = ylim;
% ylim(1.2*temp);
% title('Sinc')
% % exponential
% shapes.exponential = exp(5:-0.01:0)-1;
% subplot(3,2,5)
% plot(shapes.exponential)
% axis tight
% temp = ylim;
% ylim(1.2*temp);
% title('Exponential')

%% jitter selectivity


% create all shapes with width of 20 ms
width = 20; % width of shapes in time steps
shapes = zeros(width,6);
% triangle
shapeNames{1} = 'Triangle';
temp = linspace(0,1,10);
shapes(:,1) = [temp temp(end-1:-1:1) NaN];
% square
shapeNames{2} = 'Square';
shapes(2:end-1,2) = 1;
% gaussian
shapeNames{3} = 'Gaussian';
shapes(:,3) = normpdf(1:20,10.5,2);
% sinc
shapeNames{4} = 'Sinc';
shapes(:,4) = sinc( linspace(-pi/2,pi/2,20) );
% exponential
shapeNames{5} = 'Exponential';
shapes(:,5) = exp( linspace(1,0,20) ) - 1;
% cos
shapeNames{6} = 'Cosine';
shapes(:,6) = cos( linspace(-pi,pi,20) );


% plot shapes
figure(31)
for nShape = 1:length(shapeNames)
    subplot(3,2,nShape)
    plot(shapes(:,nShape))
    axis tight
    ylim( ylim + [-0.2, 0.2]*(max(ylim)-min(ylim)) )
    title(shapeNames(nShape))
end

figure(32)

% generate single pairs of spikes with jitters varying from 0 to 19 ms
% spikes is (number of time steps)x(number of neurons)x(number of spike
% trains).
spikes = zeros(20,2,20);
spikes(1,1,:) = 1; % in all spike trains, the first neuron spikes in the first time step
for jitter = 0:19
    % for each jitter value
    ind = jitter+1; % index where we will put spike, and also which spike train we will put it in
    spikes(ind,2,ind) = 1; % put spike in the second neuron
end

% try all jitters with all shapes
for nSpikes = 1:size(spikes,3)
    % for each pair of spike trains
    for nShape = 1:size(shapes,2)
        % for each shape
        
        % replace each spike with the shape by doing a convolution
        wave1 = conv(squeeze(spikes(:,1,nSpikes)), shapes(:,nShape));
        wave2 = conv(squeeze(spikes(:,2,nSpikes)), shapes(:,nShape)); 
        
%         figure(1)
%         hold all
%         plot(wave1)
%         plot(wave2)
%         pause
        
        % take the covariance to get the measure of synchrony
        temp = cov(wave1,wave2);
        sync(nSpikes,nShape) = temp(1,2);
        
    end
end

% normalize the synchrony measure for each shape
sync = (sync - ones(size(sync,1),1)*min(sync));
sync = sync ./ (ones(size(sync,1),1)*max(sync));

% plot results
hold all 
plot(sync)
ylabel('Synchrony measure')
xlabel('Jitter (ms)')
legend(shapeNames)


% compare to binning?