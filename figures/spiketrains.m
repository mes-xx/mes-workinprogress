close all


% make some spike trains. each row is one time step, each column is one
% spike train
load examplespikes

binlines = zeros(size(spikes,1),1);
%binlines(5:5:end) = 1;


figure
hold all

% make sure trains  are at least 100,000 elements long so that the spikes
% look like vertical lines, not triangles
[oldlength nTrains] = size(spikes);
newlength = 1e5;
scale = ceil(newlength / oldlength);
if scale > 1
    newlength = oldlength * scale;
    newspikes = zeros(newlength, nTrains);
    newspikes( scale.*find(spikes==1) ) = 1;
    spikes = newspikes;
    newbinlines = zeros(newlength, 1);
    newbinlines( scale*find(binlines==1) ) = 1;
    binlines = newbinlines;
end

dy = 0.5;
for col = 1:nTrains
    plot(spikes(:,col)+dy,'k','LineWidth',2)
    dy = dy+2;
end

stem(binlines*dy,'-k','MarkerSize',1)

axis([0 newlength 0.1 dy])
axis off