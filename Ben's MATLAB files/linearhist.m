function output = linearhist(input, nbins)
%creates a histogram of the input data set, using nbins bins of equal size;
%if only an input is specified, 50 bins are sorted by default

if nargin==1
    nbins = 50;
end

input = input(:);
nbins = nbins(1);
length = size(input);
length = length(1);
binsize = (biggie - smallie)/nbins;

biggie = max(input);
smallie = min(input);

output = zeros(1, nbins);

input = input - smallie;

for i=1:length
    tempie = ceil( input(i)/binsize );
    output(tempie) = output(tempie) + 1;
end