function output = binrate(input, window)
%sums window sized chunks of the rows of input

dimen = size(input);
window = window(1);

output = zeros((dimen(1) - window + 1),dimen(2));

for i=1:(dimen(1) - window + 1);
    output(i,:) = sum( input( (i:(i + window - 1)),: ) );
end