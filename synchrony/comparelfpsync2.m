rowcol = [4 19; 1 17; 3 13; 21 22; 10 16];
len = size(datadec,2);

for ii = 1:size(rowcol,1)

    [rho pval] = corr(squeeze(filtered(rowcol(ii,1), rowcol(ii,2),1:len)), datadec');
    
    allrho(ii,:) = rho;
    allpval(ii,:) = pval;
end