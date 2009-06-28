for ii = 1:length(s)

    z(ii,:,:) = squeeze(y(ii,:,:)) + squeeze(y(ii,:,:))';

end

z = zeros(size(y));
for ii = 1:length(s)
    for jj = 1:size(y,2)
        for kk = 1:size(y,3)
            z(ii,jj,kk) = max([y(ii,jj,kk), y(ii,kk,jj)]);
        end
    end
    
    surf(squeeze(z(ii,:,:)))
end

