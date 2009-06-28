function output = arrayRMS(input, window)
%computes RMS vectors from the columns of input

dimen = size(input);
window = window(1);

output = zeros((dimen(1) - window + 1), dimen(2));

for i=1:(dimen(1) - window + 1)
    output(i,:) = sqrt( mean( (input((i:(i + window - 1)),:)).^2 ) );
end
