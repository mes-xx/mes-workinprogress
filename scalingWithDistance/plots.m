files = dir('./');

bigwith = [];
bigagainst = [];

for ii = 4:length(files)
   load(files(ii).name)
   bigwith(:,:,ii) = with;
   bigagainst(:,:,ii) = against;
   clear with against
end

bigwith = nanmean( bigwith, 3);
bigagainst = nanmean(bigagainst, 3);

figure
for nTarg = 1:8
    subplot(4,2,nTarg)
    stem( bigwith(nTarg,:) )
    hold all;
    stem( bigagainst(nTarg,:) )
    hold off
end