function twav = strobe2twav( strobe, twid )
% strobe2twav(strobe, twid) takes in a strobe array (from snip2strobe) and
% returns a triangle wave with triangles of width twid

%twid must be odd, so make it odd!
if mod(twid, 2) == 0
    twid = twid - 1;
end %if

% make the standard triangle that is twid elements wide
step = 1 ./ ceil(twid ./ 2);
triangle = [ step:step:1 (1-step):-step:step]';

for col = 1:size(strobe,2) %for each column (channel) in the strobe

    %convolute with triangle to make the twav
    twav(:,col) = conv( strobe(:,col), triangle );

end %for