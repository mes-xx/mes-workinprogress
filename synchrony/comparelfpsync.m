% Correlates LFP to synchrony measures

lfp = load('results20080612d','data');
sync = load('results20080612c', 'syncs','colLookup');

lfp.data = lfp.data';

% downsample lfp to match sync signal (assume that the duration of both is
% the same)
sync.steps = size(sync.syncs,3);
lfp.steps = size(lfp.data,1);

keyboard

interval = lfp.steps / sync.steps;
lfp.downsampled = lfp.data(1:interval:end,:);

out = [];

for c1 = 1:size(syncs,1)
    for c2 = (c1+1):size(syncs,2)
        [chan1 sort1] = find(sync.colLookup == c1,1);
        [chan2 sort2] = find(sync.colLookup == c2,1);
        
        r1 = corr(squeeze(sync.syncs(c1,c2,:)),lfp.downsampled(:,chan1)); 
        r2 = corr(squeeze(sync.syncs(c1,c2,:)),lfp.downsampled(:,chan2));
        
        out = [out; c1 c2 chan1 r1; c1 c2 chan2 r2];
    end
end