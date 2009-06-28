% takes covariance of twav using different block sizes. output is a cell
% array where each the index of each cell is the block size (in ms)

len = 6104;
sync = [];

for n=1:len:size(twav,1)
    
    covariance = cov( twav( n:(n+len-1) , : ) );
    
    sync(end+1, :) = [ covariance(1,2) covariance(1,3) covariance(2,3) ];
    
end