figure
hold all
keys = cell(size(y,1),1);
for ii = 1:size(y,1)
    surf(r, r, squeeze(y(ii,:,:)))
    keys{ii} = num2str( s(ii) );
end
xlabel('Firing rate 2')
ylabel('Firing rate 1')
zlabel('CPS value')
title('Synchrony of simulated spike trains')
legend(keys)

